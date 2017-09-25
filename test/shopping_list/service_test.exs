defmodule ShoppingList.ServiceTest do
  use ExUnit.Case, async: false
  alias ShoppingList.{Entry, Service, Service.Discovery}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ShoppingList.EctoRepo)
    Ecto.Adapters.SQL.Sandbox.mode(ShoppingList.EctoRepo, {:shared, self()})
    :ok
  end


  # -------------------------------------------------------------------
  # Tests
  # -------------------------------------------------------------------

  test "initial service state" do
    list_id = start_service!()
    assert list_entries(list_id) == []
  end

  test "adding an element" do
    list_id = start_service!()
    assert Service.add_entry(list_id, "1", "eggs", 12) == :ok
    assert list_entries(list_id) == [%Entry{id: "1", name: "eggs", quantity: 12}]
  end

  test "deleting an element" do
    list_id = start_service!()
    Service.add_entry(list_id, "1", "eggs", 12)
    assert Service.delete_entry(list_id, "1") == :ok
    assert list_entries(list_id) == []
  end

  test "updating an existing element" do
    list_id = start_service!()
    Service.add_entry(list_id, "1", "eggs", 12)
    assert Service.update_entry_quantity(list_id, "1", 24) == :ok
    assert list_entries(list_id) == [%Entry{id: "1", name: "eggs", quantity: 24}]
  end

  test "isolation of services with different names" do
    list1 = start_service!()
    list2 = start_service!()

    Service.add_entry(list1, "1", "eggs", 12)
    Service.add_entry(list2, "1", "biers", 6)

    assert list_entries(list1) == [%Entry{id: "1", name: "eggs", quantity: 12}]
    assert list_entries(list2) == [%Entry{id: "1", name: "biers", quantity: 6}]
  end

  test "restoring of the data" do
    list_id = start_service!()
    Service.add_entry(list_id, "1", "eggs", 12)
    Service.add_entry(list_id, "2", "biers", 6)
    Service.delete_entry(list_id, "1")
    Service.update_entry_quantity(list_id, "2", 24)
    Service.stop(list_id)
    Service.subscribe(list_id)

    assert list_entries(list_id) == [%Entry{id: "2", name: "biers", quantity: 24}]
  end

  test "subscribing" do
    list_id = start_service!()
    assert [] == Service.subscribe(list_id)
  end

  test "subscriber receives the entry_added event" do
    list_id = start_service!()
    Service.subscribe(list_id)
    Service.add_entry(list_id, "1", "eggs", 12)
    assert_receive {:shopping_list_event,
      %{event_name: :entry_added, id: "1", name: "eggs", quantity: 12}}
  end

  test "subscriber receives the entry_quantity_updated event" do
    list_id = start_service!()
    Service.subscribe(list_id)
    Service.add_entry(list_id, "1", "eggs", 12)
    Service.update_entry_quantity(list_id, "1", 6)
    assert_receive {:shopping_list_event,
      %{event_name: :entry_quantity_updated, id: "1", quantity: 6}}
  end

  test "subscriber receives the entry_deleted event" do
    list_id = start_service!()
    Service.subscribe(list_id)
    Service.add_entry(list_id, "1", "eggs", 12)
    Service.delete_entry(list_id, "1")
    assert_receive {:shopping_list_event, %{event_name: :entry_deleted, id: "1"}}
  end

  test "service is stopped when there are no subscribers" do
    list_id = Service.new_id()
    subscriber = start_subscriber(list_id)
    pid = Discovery.whereis(Service, list_id)
    Process.monitor(pid)
    Task.shutdown(subscriber, :brutal_kill)

    assert_receive {:DOWN, _mref, :process, ^pid, :shutdown}
  end

  test "service is not stopped if there is at least one subscriber" do
    list_id = Service.new_id()
    start_subscriber(list_id)
    pid = Discovery.whereis(Service, list_id)
    Process.monitor(pid)

    refute_receive {:DOWN, _mref, :process, ^pid, :normal}
  end


  # -------------------------------------------------------------------
  # Internal functions
  # -------------------------------------------------------------------

  defp start_service!() do
    Process.flag(:trap_exit, true)
    list_id = Service.new_id()
    Service.subscribe(list_id)
    list_id
  end

  defp list_entries(list_id) do
    service_state =
      ShoppingList.SubscriptionService
      |> Discovery.whereis(list_id)
      |> :sys.get_state()

    ShoppingList.entries(service_state.shopping_list)
  end

  defp start_subscriber(list_id) do
    test_process = self()

    subscriber =
      Task.async(fn ->
        Service.subscribe(list_id)
        send(test_process, :subscribed)
        :timer.sleep(:infinity)
      end)

    assert_receive :subscribed

    subscriber
  end
end
