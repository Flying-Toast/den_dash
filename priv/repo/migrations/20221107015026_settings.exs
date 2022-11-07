defmodule DenDash.Repo.Migrations.Settings do
  use Ecto.Migration
  import Ecto.Changeset
  alias DenDash.{Repo, Settings}

  def change do
    create table(:settings) do
      add :order_cost, :string, null: false
      add :open_now, :boolean, null: false
    end
  end
end
