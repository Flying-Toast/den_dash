defmodule DenDashWeb.OrderController do
  use DenDashWeb, :controller
  alias DenDash.{Orders, Orders.Order}

  def order_form(conn, _params) do
    changeset = Order.changeset(%Order{})
    render(conn, "order_form.html", changeset: changeset)
  end

  def create(conn, %{"order" => order}) do
    case Orders.new_order(conn.assigns.me, order) do
      {:ok, changeset} ->
        conn
        |> put_flash(:info, "Your order has been saved. Please finish payment to complete your delivery order.")
        |> redirect(to: Routes.order_path(conn, :show, changeset.id))

      {:error, changeset} ->
        render(conn, "order_form.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    order = Orders.get_order!(id)
    render(conn, "show_order.html", title: "Order ##{order.number}", order: order)
  end

  def list(conn, _params) do
    my_orders = Orders.list_orders_for_user(conn.assigns.me)
    render(conn, "list_orders.html", title: "Your Orders", orders: my_orders)
  end

  def pay(conn, %{"id" => id}) do
    order = Orders.get_order!(id)

    if order.paid do
      render(conn, "already_paid.html")
    else
      recipient = Application.fetch_env!(:den_dash, :venmo_recipient)
      amount = Application.fetch_env!(:den_dash, :order_cost)
      venmo_url = "https://venmo.com/?txn=pay&audience=friends&recipients=#{recipient}&amount=#{amount}&note=🥞%20DenDash:%20!#{order.venmo_note_tag}!%20Paid"

      if Orders.should_show_payment_tutorial_for_user(conn.assigns.me) do
        render(conn, "payment_tutorial.html", venmo_url: venmo_url)
      else
        redirect(conn, external: venmo_url)
      end
    end
  end
end
