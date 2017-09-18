defmodule ShoppingList.ServiceTest do
  use ExUnit.Case
  alias ShoppingList.{Entry, Service}


  # -------------------------------------------------------------------
  # Tests
  # -------------------------------------------------------------------

  test "initial service state" do
    {:ok, pid} = Service.start_link()
    assert Service.entries(pid) == []
  end

  test "adding an element" do
    {:ok, pid} = Service.start_link()
    assert Service.add_entry(pid, "eggs", 12) == :ok
    assert Service.entries(pid) == [%Entry{id: 1, name: "eggs", quantity: 12}]
  end

  test "deleting an element" do
    {:ok, pid} = Service.start_link()
    Service.add_entry(pid, "eggs", 12)
    assert Service.delete_entry(pid, 1) == :ok
    assert Service.entries(pid) == []
  end

  test "updating an existing element" do
    {:ok, pid} = Service.start_link()
    Service.add_entry(pid, "eggs", 12)
    assert Service.update_entry_quantity(pid, 1, 24) == :ok
    assert Service.entries(pid) == [%Entry{id: 1, name: "eggs", quantity: 24}]
  end
end
