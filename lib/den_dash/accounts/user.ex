defmodule DenDash.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias DenDash.Orders.Order

  schema "users" do
    field :caseid, :string
    field :is_regular_employee, :boolean
    has_many :orders, Order

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:caseid, :is_regular_employee])
    |> validate_required([:caseid, :is_regular_employee])
  end
end
