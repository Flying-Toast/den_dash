defmodule DenDash.Repo.Migrations.OrderDeliveredField do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :delivered, :boolean, null: false, default: false
    end
  end
end
