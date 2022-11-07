defmodule DenDashWeb.FulfilmentController do
  use DenDashWeb, :controller
  alias DenDash.{Repo, Orders, Fulfilment.DeliveryNotifier, Settings}

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

  def settings(conn, _params) do
    settings = Settings.get()
               |> Settings.changeset(%{})
    render(conn, "settings.html", title:  "Settings ⚙️", settings: settings)
  end

  def change_settings(conn, %{"settings" => settings}) do
    case Settings.get() |> Settings.changeset(settings) |> Repo.update() do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Settings saved.")
        |> redirect(to: Routes.fulfilment_path(conn, :settings))

      {:error, changeset} ->
        render(conn, "settings.html", title: "Settings ⚙️", settings: changeset)
    end
  end
end
