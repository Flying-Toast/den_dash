defmodule DenDash.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias DenDash.Accounts.User

  schema "orders" do
    belongs_to :user, User
    field :number, :integer
    field :paid, :boolean
    field :venmo_note_tag, :string
    field :grubhub_name, :string
    field :picked_up, :boolean
    field :delivered, :boolean

    timestamps(type: :utc_datetime)
  end

  def changeset(order, attrs \\ %{}) do
    order
    # cast is USER-EDITABLE stuff
    |> cast(attrs, [:number, :grubhub_name])
    |> validate_required([:number, :venmo_note_tag, :paid, :grubhub_name, :delivered, :picked_up])
    |> validate_number(:number, greater_than: 0)
    |> validate_length(:grubhub_name, max: 150)
  end
end
