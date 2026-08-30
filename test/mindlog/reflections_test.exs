defmodule Mindlog.ReflectionsTest do
  use Mindlog.DataCase, async: true

  alias Mindlog.Reflections

  describe "entries" do
    test "create_entry/1 persists analyzer-derived counts" do
      assert {:ok, entry} =
               Reflections.create_entry(
                 "I feel hopeful and grateful, but anxious after a nightmare."
               )

      assert entry.word_count == 10
      assert entry.analysis["emotions"]["hope"]["mentions"] == 1
      assert entry.analysis["emotions"]["joy"]["mentions"] == 1
      assert entry.analysis["emotions"]["fear"]["mentions"] == 1
      assert entry.analysis["trauma_language"]["mentions"] == 1
    end

    test "create_entry/1 rejects a blank reflection" do
      assert {:error, changeset} = Reflections.create_entry("   ")
      assert %{body: ["can't be blank"]} = errors_on(changeset)
    end

    test "list_entries/0 returns newest reflections first" do
      assert {:ok, first} = Reflections.create_entry("I am hopeful today.")
      assert {:ok, second} = Reflections.create_entry("I am sad this evening.")

      assert [^second, ^first] = Reflections.list_entries()
    end

    test "delete_entry/1 removes a reflection" do
      assert {:ok, entry} = Reflections.create_entry("I feel calm today.")
      assert {:ok, _entry} = Reflections.delete_entry(entry)
      assert_raise Ecto.NoResultsError, fn -> Reflections.get_entry!(entry.id) end
    end
  end
end
