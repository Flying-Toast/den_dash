defmodule DenDash.Repo.Migrations.OrderVenmoNoteTag do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :venmo_note_tag, :string, null: false, default: ""
    end
  end
end
