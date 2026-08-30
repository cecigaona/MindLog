defmodule Mindlog.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :body, :text, null: false
      add :word_count, :integer, null: false
      add :analysis, :map, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
