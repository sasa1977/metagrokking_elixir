defmodule ShoppingListWeb.NotificationChannelTest do
  use ShoppingListWeb.ChannelCase, async: false


  # -------------------------------------------------------------------
  # Tests
  # -------------------------------------------------------------------

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ShoppingList.EctoRepo)
    Ecto.Adapters.SQL.Sandbox.mode(ShoppingList.EctoRepo, {:shared, self()})
    :ok
  end

  test "list entries are returned on initial connect" do
    list_id = ShoppingList.new_id()

    fn ->
      ShoppingList.Service.subscribe(list_id)
      ShoppingList.Service.add_entry(list_id, "1", "eggs", 12)

      Process.flag(:trap_exit, true)
      ShoppingList.Service.stop(list_id)
    end
    |> Task.async()
    |> Task.await()

    signed_list_id = ShoppingListWeb.sign_list_id(list_id)
    {:ok, socket} = connect(ShoppingListWeb.Socket, nil)
    {:ok, response, _socket} = subscribe_and_join(socket, "notifications:#{signed_list_id}", %{})
    assert response == %{entries: [%ShoppingList.Entry{id: "1", name: "eggs", quantity: 12}]}
  end

  test "change notification is pushed on list modification" do
    list_id = ShoppingList.new_id()
    signed_list_id = ShoppingListWeb.sign_list_id(list_id)
    {:ok, socket} = connect(ShoppingListWeb.Socket, nil)
    {:ok, _, _} = subscribe_and_join(socket, "notifications:#{signed_list_id}", %{})

    ShoppingList.Service.add_entry(list_id, "1", "eggs", 12)

    assert_push("entry_added", payload)
    assert payload == %{id: "1", name: "eggs", quantity: 12}
  end
end
