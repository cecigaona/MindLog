defmodule Mindlog.Reflections do
  @moduledoc """
  Persistence and deterministic language analysis for journal reflections.
  """

  import Ecto.Query, warn: false

  alias Mindlog.Repo
  alias Mindlog.Reflections.{Entry, TextAnalyzer}

  def list_entries do
    Entry
    |> order_by([entry], desc: entry.inserted_at, desc: entry.id)
    |> Repo.all()
  end

  def get_entry!(id), do: Repo.get!(Entry, id)

  def new_entry_changeset, do: Entry.form_changeset(%Entry{}, %{})

  def create_entry(body) when is_binary(body) do
    changeset = Entry.form_changeset(%Entry{}, %{body: body})

    case Ecto.Changeset.apply_action(changeset, :insert) do
      {:ok, %{body: normalized_body}} ->
        analysis = TextAnalyzer.analyze(normalized_body)

        %Entry{}
        |> Entry.changeset(%{
          body: normalized_body,
          word_count: analysis["word_count"],
          analysis: analysis
        })
        |> Repo.insert()

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def create_entry(_), do: {:error, invalid_body_changeset()}

  def delete_entry(%Entry{} = entry), do: Repo.delete(entry)

  defp invalid_body_changeset do
    changeset = Entry.form_changeset(%Entry{}, %{})
    %{changeset | action: :insert}
  end
end
