defmodule DenDashWeb.FulfilmentController do
  use DenDashWeb, :controller
  alias DenDash.{Repo, Orders, Fulfilment.DeliveryNotifier, Settings, Accounts}

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
    render(conn, "settings.html", title: "Settings ⚙️", settings: settings)
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

  def admin(conn, _params) do
    render(conn, "admin.html", title: "Admin 📛")
  end

  def employees(conn, _params) do
    current_employees = Accounts.list_employees()

    render(conn, "employees.html", title: "Employees 👷", employees: current_employees)
  end

  def add_employee(conn, %{"caseid" => caseid}) do
    Accounts.make_employee(caseid)

    conn
    |> put_flash(:info, "Added #{caseid} as an employee")
    |> redirect(to: Routes.fulfilment_path(conn, :employees))
  end

  def remove_employee(conn, %{"user_id" => user_id}) do
    Accounts.fire_employee_by_id(user_id)

    conn
    |> put_flash(:info, "Removed employee")
    |> redirect(to: Routes.fulfilment_path(conn, :employees))
  end
end
