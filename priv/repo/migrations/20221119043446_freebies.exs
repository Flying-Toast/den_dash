defmodule DenDash.Repo.Migrations.Freebies do
  use Ecto.Migration

  def change do
    create table(:freebies) do
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
