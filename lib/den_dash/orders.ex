defmodule DenDash.Orders do
  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias DenDash.{Repo, Orders.Order}

  def list_orders_for_user(user) do
    Repo.all(from o in Order, where: o.user_id == ^user.id, order_by: [desc: :inserted_at])
  end

  def get_order!(id) do
    Repo.get!(Order, id)
  end

  def get_order_by_venmo_tag(tag) do
    Repo.one(from o in Order, where: o.venmo_note_tag == ^tag)
  end

  def should_show_payment_tutorial_for_user(user) do
    not Repo.exists?(from o in Order, where: o.user_id == ^user.id and o.paid)
  end

  def mark_order_as_paid(order) do
    order
    |> change(paid: true)
    |> Repo.update()
  end

  defp gen_venmo_tag() do
    tag =
      :crypto.strong_rand_bytes(5)
      |> Base.encode32()

    # FIXME: Race condition?
    if Repo.exists?(from o in Order, where: o.venmo_note_tag == ^tag) do
      gen_venmo_tag()
    else
      tag
    end
  end

  def new_order(user, order_attrs) do
    %Order{}
    |> change(%{
      user_id: user.id,
      venmo_note_tag: gen_venmo_tag(),
      paid: false
    })
    |> Order.changeset(order_attrs)
    |> Repo.insert()
  end
end
