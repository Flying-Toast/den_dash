defmodule DenDash.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias DenDash.Orders.Order

  schema "users" do
    field :caseid, :string
    has_many :orders, Order

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:caseid])
    |> validate_required([:caseid])
  end
end
