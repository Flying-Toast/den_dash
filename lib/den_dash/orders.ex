defmodule DenDash.Orders do
  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias DenDash.{Repo, Orders.Order, Settings}

  def unpicked_paid_orders() do
    Repo.all(from o in Order, where: o.paid and not o.picked_up)
  end

  def undelivered_picked_orders() do
    Repo.all(from o in Order, where: o.picked_up and not o.delivered)
  end

  def list_orders_for_user(user) do
    Repo.all(from o in Order, where: o.user_id == ^user.id, order_by: [desc: :inserted_at])
  end

  def get_order_for_user!(user, order_id) do
    Repo.one!(from o in Order, where: o.id == ^order_id and o.user_id == ^user.id)
  end

  def get_order_directly!(order_id) do
    Repo.get!(Order, order_id)
  end

  def delete_order(order) do
    Repo.delete(order)
  end

  def get_order_by_venmo_tag(tag) do
    Repo.one(from o in Order, where: o.venmo_note_tag == ^tag)
  end

  def mark_order_as_paid(order) do
    order
    |> change(paid: true)
    |> Repo.update()
  end

  def mark_order_as_picked_up(order) do
    order
    |> change(picked_up: true)
    |> Repo.update()
  end

  def mark_order_as_delivered(order) do
    order
    |> change(delivered: true)
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
    is_prepaid = do_first_order_promo?(user)

    %Order{}
    |> change(%{
      user_id: user.id,
      venmo_note_tag: gen_venmo_tag(),
      paid: is_prepaid,
      picked_up: false,
      delivered: false,
      price: Settings.order_cost()
    })
    |> Order.changeset(order_attrs)
    |> Repo.insert()
  end

  def user_has_unpaid_order(user) do
    Repo.exists?(from o in Order, where: o.user_id == ^user.id and not o.paid)
  end

  def do_first_order_promo?(user) do
    today = DateTime.utc_now()
            |> DateTime.shift_zone!("America/New_York")
            |> DateTime.to_date()

    (:eq == Date.compare(today, ~D[2022-11-18]))
    and
    not Repo.exists?(from o in Order, where: o.user_id == ^user.id)
  end

  def name_on_users_most_recent_order(user) do
    order = Repo.one(from o in Order, where: o.user_id == ^user.id, order_by: [desc: :inserted_at], limit: 1)

    if order do
      order.grubhub_name
    else
      ""
    end
  end
end
