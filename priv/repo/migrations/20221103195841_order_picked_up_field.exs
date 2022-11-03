defmodule DenDash.Repo.Migrations.OrderPickedUpField do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :picked_up, :boolean, null: false, default: false
    end
  end
end
