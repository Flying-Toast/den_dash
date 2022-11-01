defmodule DenDash.Repo.Migrations.OrderPayment do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :paid, :boolean, null: false, default: false
    end
  end
end
