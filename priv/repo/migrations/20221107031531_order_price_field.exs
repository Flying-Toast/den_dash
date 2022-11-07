defmodule DenDash.Repo.Migrations.OrderPriceField do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :price, :string, null: false, default: "1.00"
    end
  end
end
