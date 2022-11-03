defmodule DenDash.Repo.Migrations.OrderGrubhubNameField do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :grubhub_name, :string, null: false, default: ""
    end
  end
end
