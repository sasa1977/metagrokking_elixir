defmodule ShoppingList.ServiceTest do
  use ExUnit.Case
  alias ShoppingList.{Entry, Service}


  # -------------------------------------------------------------------
  # Tests
  # -------------------------------------------------------------------

  test "initial service state" do
    list_id = unique_list_id()
    assert Service.entries(list_id) == []
  end

  test "adding an element" do
    list_id = unique_list_id()
    assert Service.add_entry(list_id, "eggs", 12) == :ok
    assert Service.entries(list_id) == [%Entry{id: 1, name: "eggs", quantity: 12}]
  end

  test "deleting an element" do
    list_id = unique_list_id()
    Service.add_entry(list_id, "eggs", 12)
    assert Service.delete_entry(list_id, 1) == :ok
    assert Service.entries(list_id) == []
  end

  test "updating an existing element" do
    list_id = unique_list_id()
    Service.add_entry(list_id, "eggs", 12)
    assert Service.update_entry_quantity(list_id, 1, 24) == :ok
    assert Service.entries(list_id) == [%Entry{id: 1, name: "eggs", quantity: 24}]
  end

  test "isolation of services with different names" do
    list1 = unique_list_id()
    list2 = unique_list_id()

    Service.add_entry(list1, "eggs", 12)
    Service.add_entry(list2, "biers", 6)

    assert Service.entries(list1) == [%Entry{id: 1, name: "eggs", quantity: 12}]
    assert Service.entries(list2) == [%Entry{id: 1, name: "biers", quantity: 6}]
  end


  # -------------------------------------------------------------------
  # Internal functions
  # -------------------------------------------------------------------

  defp unique_list_id(), do:
    :erlang.unique_integer([:positive, :monotonic])
end
