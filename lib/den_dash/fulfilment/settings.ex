defmodule DenDash.Settings do
  use Ecto.Schema
  import Ecto.Changeset
  alias DenDash.{Repo, Settings}

  schema "settings" do
    field :order_cost, :string
    field :open_now, :boolean
  end

  def changeset(settings, attrs) do
    settings
    |> cast(attrs, [:open_now, :order_cost])
    |> validate_format(:order_cost, ~r/^\d+\.\d\d$/)
  end

  def get() do
    Repo.one(Settings)
  end

  def prefill_defaults() do
    if not Repo.exists?(Settings) do
      %Settings{}
      |> change(order_cost: "1.00")
      |> change(open_now: false)
      |> Repo.insert()
    end
  end

  def order_cost() do
    get().order_cost
  end
end
