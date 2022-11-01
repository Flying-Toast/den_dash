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
        |> put_flash(:info, "Your order was placed successfully!")
        |> redirect(to: Routes.order_path(conn, :show, changeset.id))

      {:error, changeset} ->
        render(conn, "order_form.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    order = Orders.get_order!(id)
    render(conn, "show_order.html", order: order)
  end
end
