defmodule DenDashWeb.OrderController do
  use DenDashWeb, :controller
  alias DenDash.{Orders, Orders.Order}

  def order_form(conn, _params) do
    changeset = Order.changeset(%Order{}, %{grubhub_name: Orders.name_on_users_most_recent_order(conn.assigns.me)})
    render(conn, "order_form.html", title: "Submit Order 📝", changeset: changeset)
  end

  def create(conn, %{"order" => order}) do
    if Orders.user_has_unpaid_order(conn.assigns.me) do
      conn
      |> put_flash(:error, "You have another order that has not yet been paid. Please complete payment or cancel it before placing another.")
      |> render("order_form.html", title: "Submit Order 📝", changeset: Order.changeset(%Order{}, order))
    else
      case Orders.new_order(conn.assigns.me, order) do
        {:ok, changeset} ->
          conn
          |> put_flash(:info, "Your order has been saved.")
          |> redirect(to: Routes.order_path(conn, :show, changeset.id))

        {:error, changeset} ->
          render(conn, "order_form.html", title: "Submit Order 📝", changeset: changeset)
      end
    end
  end

  def show(conn, %{"id" => id}) do
    order = Orders.get_order_for_user!(conn.assigns.me, id)
    render(conn, "show_order.html", title: "Order ##{order.number} 🥡", order: order)
  end

  def list(conn, _params) do
    my_orders = Orders.list_orders_for_user(conn.assigns.me)
    render(conn, "list_orders.html", title: "Your Orders 📦", orders: my_orders)
  end

  def pay(conn, %{"id" => id}) do
    order = Orders.get_order_for_user!(conn.assigns.me, id)

    if order.paid do
      render(conn, "payment_received.html", title: "Payment Received 👍")
    else
      recipient = Application.fetch_env!(:den_dash, :venmo_recipient)
      amount = Application.fetch_env!(:den_dash, :order_cost)
      venmo_url = "https://venmo.com/?txn=pay&audience=friends&recipients=#{recipient}&amount=#{amount}&note=🥞%20DenDash:%20!#{order.venmo_note_tag}!%20Paid"

      render(conn, "payment_tutorial.html", title: "Payment 💰", venmo_url: venmo_url)
    end
  end

  def cancel(conn, %{"id" => id}) do
    order = Orders.get_order_for_user!(conn.assigns.me, id)

    if order.paid do
      conn
      |> put_flash(:error, "You cannot cancel this order because it has already been processed.")
      |> redirect(to: Routes.order_path(conn, :show, order.id))
    else
      Orders.delete_order(order)

      conn
      |> put_flash(:info, "Order ##{order.number} has been cancelled.")
      |> redirect(to: Routes.order_path(conn, :list))
    end
  end
end
