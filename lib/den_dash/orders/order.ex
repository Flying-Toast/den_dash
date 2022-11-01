defmodule DenDash.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias DenDash.Accounts.User

  schema "orders" do
    belongs_to :user, User
    field :number, :integer

    timestamps(type: :utc_datetime)
  end

  # changeset is USER-EDITABLE stuff & associated validation
  def changeset(order, attrs \\ %{}) do
    order
    |> cast(attrs, [:number])
    |> validate_required([:number])
    |> validate_number(:number, greater_than: 0)
  end
end
