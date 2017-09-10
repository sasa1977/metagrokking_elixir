defmodule ShoppingListTest do
  use ExUnit.Case, async: true
  alias ShoppingList.Entry


  # -------------------------------------------------------------------
  # Tests
  # -------------------------------------------------------------------

  test "empty list" do
    list = ShoppingList.new()

    assert ShoppingList.size(list) == 0
    assert ShoppingList.entries(list) == []
  end

  test "one-element list" do
    list =
      ShoppingList.new()
      |> ShoppingList.add_entry("eggs", 12)

    assert ShoppingList.size(list) == 1
    assert sorted_entries(list) == [%Entry{id: 1, name: "eggs", quantity: 12}]
  end

  test "two-elements list" do
    list =
      ShoppingList.new()
      |> ShoppingList.add_entry("biers", 6)
      |> ShoppingList.add_entry("eggs", 12)

    assert ShoppingList.size(list) == 2
    assert sorted_entries(list) == [
      %Entry{id: 1, name: "biers", quantity: 6},
      %Entry{id: 2, name: "eggs", quantity: 12}
    ]
  end

  test "deleting an existing element" do
    list =
      ShoppingList.new()
      |> ShoppingList.add_entry("eggs", 12)
      |> ShoppingList.add_entry("biers", 6)
      |> ShoppingList.delete_entry(2)

    assert ShoppingList.size(list) == 1
    assert sorted_entries(list) == [%Entry{id: 1, name: "eggs", quantity: 12}]
  end

  test "deleting a non-existing element" do
    list =
      ShoppingList.new()
      |> ShoppingList.add_entry("eggs", 12)
      |> ShoppingList.add_entry("biers", 6)
      |> ShoppingList.delete_entry(3)

    assert ShoppingList.size(list) == 2
  end

  test "changing entry quantity" do
    list =
      ShoppingList.new()
      |> ShoppingList.add_entry("eggs", 12)
      |> ShoppingList.add_entry("biers", 6)
      |> ShoppingList.update_entry_quantity(2, 18)

    assert ShoppingList.size(list) == 2
    assert sorted_entries(list) == [
      %Entry{id: 1, name: "eggs", quantity: 12},
      %Entry{id: 2, name: "biers", quantity: 18}
    ]
  end


  # -------------------------------------------------------------------
  # Internal functions
  # -------------------------------------------------------------------

  defp sorted_entries(shopping_list), do:
    shopping_list
    |> ShoppingList.entries()
    |> Enum.sort_by(&(&1.id))
end
