defmodule ShoppingListTest do
  use ExUnit.Case, async: true


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
    assert ShoppingList.entries(list) == [%{name: "eggs", quantity: 12}]
  end

  test "two-elements list" do
    list =
      ShoppingList.new()
      |> ShoppingList.add_entry("biers", 6)
      |> ShoppingList.add_entry("eggs", 12)

    assert ShoppingList.size(list) == 2
    sorted_entries = list |> ShoppingList.entries() |> Enum.sort_by(&(&1.name))
    assert sorted_entries ==
      [
        %{name: "biers", quantity: 6},
        %{name: "eggs", quantity: 12}
      ]
  end
end
