defmodule DenDash.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias DenDash.Accounts.User

  schema "orders" do
    belongs_to :user, User
    field :number, :integer
    field :paid, :boolean
    field :venmo_note_tag, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(order, attrs \\ %{}) do
    order
    # cast is USER-EDITABLE stuff
    |> cast(attrs, [:number])
    |> validate_required([:number, :venmo_note_tag, :paid])
    |> validate_number(:number, greater_than: 0)
  end
end
