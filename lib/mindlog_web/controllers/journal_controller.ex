defmodule MindlogWeb.JournalController do
  use MindlogWeb, :controller

  alias Mindlog.Reflections

  def index(conn, _params) do
    render_index(conn, Reflections.new_entry_changeset())
  end

  def create(conn, %{"entry" => entry_params}) do
    case Reflections.create_entry(Map.get(entry_params, "body")) do
      {:ok, entry} ->
        conn
        |> put_flash(:info, "Reflection saved. Review the transparent language counts below.")
        |> redirect(to: ~p"/entries/#{entry}")

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render_index(changeset)
    end
  end

  def create(conn, _params) do
    {:error, changeset} = Reflections.create_entry(nil)

    conn
    |> put_status(:unprocessable_entity)
    |> render_index(changeset)
  end

  def show(conn, %{"id" => id}) do
    entry = Reflections.get_entry!(id)
    render(conn, :show, entry: entry, page_title: "Reflection analysis")
  end

  def delete(conn, %{"id" => id}) do
    entry = Reflections.get_entry!(id)
    {:ok, _entry} = Reflections.delete_entry(entry)

    conn
    |> put_flash(:info, "Reflection deleted.")
    |> redirect(to: ~p"/")
  end

  defp render_index(conn, changeset) do
    render(conn, :index,
      entries: Reflections.list_entries(),
      form: Phoenix.Component.to_form(changeset, as: :entry),
      page_title: "MindLog"
    )
  end
end
