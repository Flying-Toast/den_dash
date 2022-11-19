defmodule DenDash.Orders.Freebie do
  use Ecto.Schema
  import Ecto.Changeset
  alias DenDash.Accounts.User

  schema "freebies" do
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  def changeset(freebie, attrs \\ %{}) do
    freebie
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
  end
end
