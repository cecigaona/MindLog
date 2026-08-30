defmodule MindlogWeb.JournalControllerTest do
  use MindlogWeb.ConnCase, async: true

  alias Mindlog.Reflections

  test "GET / renders the journal form", %{conn: conn} do
    conn = get(conn, ~p"/")

    assert html_response(conn, 200) =~ "A journal with transparent language signals."
  end

  test "POST /entries persists a reflection and redirects to its analysis", %{conn: conn} do
    conn =
      post(conn, ~p"/entries", %{"entry" => %{"body" => "I feel hopeful and grateful today."}})

    assert redirected_to(conn) =~ "/entries/"
    [entry] = Reflections.list_entries()
    assert entry.analysis["emotions"]["hope"]["mentions"] == 1

    conn = get(recycle(conn), ~p"/entries/#{entry}")
    assert html_response(conn, 200) =~ "Emotion word counts"
  end

  test "POST /entries returns a validation error for a blank reflection", %{conn: conn} do
    conn = post(conn, ~p"/entries", %{"entry" => %{"body" => " "}})

    assert html_response(conn, 422) =~ "can&#39;t be blank"
  end

  test "shows a support notice when urgent-support language is matched", %{conn: conn} do
    assert {:ok, entry} = Reflections.create_entry("I want to die.")

    conn = get(conn, ~p"/entries/#{entry}")

    assert html_response(conn, 200) =~ "Consider immediate human support"
  end

  test "DELETE /entries/:id removes a reflection", %{conn: conn} do
    assert {:ok, entry} = Reflections.create_entry("I feel calm today.")

    conn = delete(conn, ~p"/entries/#{entry}")

    assert redirected_to(conn) == ~p"/"
    assert_raise Ecto.NoResultsError, fn -> Reflections.get_entry!(entry.id) end
  end
end
