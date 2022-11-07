defmodule DenDash.Repo.Migrations.EmployeeUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_regular_employee, :boolean, null: false, default: false
    end
  end
end
