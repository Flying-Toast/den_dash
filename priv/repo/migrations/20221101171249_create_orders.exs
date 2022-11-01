defmodule DenDash.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :number, :integer, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
