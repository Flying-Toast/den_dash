defmodule DenDashWeb.FulfilmentController do
  use DenDashWeb, :controller
  alias DenDash.{Orders, Fulfilment.DeliveryNotifier}

  def index(conn, _params) do
    pickups = Orders.unpicked_paid_orders()
    deliveries = Orders.undelivered_picked_orders()

    render(conn, "index.html", title: "Fulfilment 🛠️", pickups: pickups, deliveries: deliveries)
  end

  def picked_up(conn, %{"id" => id}) do
    order = Orders.get_order_directly!(id)
    Orders.mark_order_as_picked_up(order)
    DeliveryNotifier.deliver_order_picked_up(order)

    redirect(conn, to: Routes.fulfilment_path(conn, :index))
  end

  def delivered(conn, %{"id" => id}) do
    order = Orders.get_order_directly!(id)
    Orders.mark_order_as_delivered(order)
    DeliveryNotifier.deliver_order_delivered(order)

    redirect(conn, to: Routes.fulfilment_path(conn, :index))
  end
end
