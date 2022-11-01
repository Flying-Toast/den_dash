defmodule DenDash.Orders do
  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias DenDash.{Repo, Orders.Order}

  def list_orders_for_user(user) do
    Repo.all(from o in Order, where: o.user_id == ^user.id)
  end

  def get_order!(id) do
    Repo.get!(Order, id)
  end

  def new_order(user, order_attrs) do
    %Order{}
    |> Order.changeset(order_attrs)
    |> change(user_id: user.id)
    |> Repo.insert()
  end
end
