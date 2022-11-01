defmodule DenDash.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :caseid, :string

      timestamps(type: :utc_datetime)
    end
  end
end
