defmodule Mindlog.Reflections.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  @max_body_length 10_000

  schema "entries" do
    field :body, :string
    field :word_count, :integer
    field :analysis, :map

    timestamps(type: :utc_datetime)
  end

  def form_changeset(entry, attrs) do
    entry
    |> cast(attrs, [:body])
    |> update_change(:body, &String.trim/1)
    |> validate_required([:body])
    |> validate_length(:body, min: 3, max: @max_body_length)
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:body, :word_count, :analysis])
    |> validate_required([:body, :word_count, :analysis])
    |> validate_length(:body, min: 3, max: @max_body_length)
    |> validate_number(:word_count, greater_than_or_equal_to: 0)
  end
end
