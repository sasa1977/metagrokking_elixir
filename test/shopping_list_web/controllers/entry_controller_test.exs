defmodule ShoppingListWeb.EntryControllerTest do
  use ShoppingListWeb.ConnCase, async: false


  # -------------------------------------------------------------------
  # Tests
  # -------------------------------------------------------------------

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ShoppingList.EctoRepo)
    Ecto.Adapters.SQL.Sandbox.mode(ShoppingList.EctoRepo, {:shared, self()})
    :ok
  end

  test "creating an entry", %{conn: conn} do
    list_id = start_service!()

    conn =
      post(
        conn,
        list_entry_path(conn, :create, ShoppingListWeb.sign_list_id(list_id)),
        id: "1", name: "eggs", quantity: 12
      )

    assert response(conn, 200)
    assert list_entries(list_id) == [%ShoppingList.Entry{id: "1", name: "eggs", quantity: 12}]
  end

  test "updating an entry quantity", %{conn: conn} do
    list_id = start_service!()
    ShoppingList.Service.add_entry(list_id, "1", "eggs", 12)
    entry_id = hd(list_entries(list_id)).id

    conn =
      put(
        conn,
        list_entry_path(conn, :update, ShoppingListWeb.sign_list_id(list_id), entry_id),
        quantity: 6
      )

    assert response(conn, 200)
    assert list_entries(list_id) == [%ShoppingList.Entry{id: "1", name: "eggs", quantity: 6}]
  end

  test "deleting an entry", %{conn: conn} do
    list_id = start_service!()
    ShoppingList.Service.add_entry(list_id, "1", "eggs", 12)
    entry_id = hd(list_entries(list_id)).id

    conn =
      delete(
        conn,
        list_entry_path(conn, :delete, ShoppingListWeb.sign_list_id(list_id), entry_id)
      )

    assert response(conn, 200)
    assert list_entries(list_id) == []
  end


  # -------------------------------------------------------------------
  # Internal functions
  # -------------------------------------------------------------------

  defp start_service!() do
    Process.flag(:trap_exit, true)
    list_id = ShoppingList.new_id()
    ShoppingList.Service.subscribe(list_id)
    list_id
  end

  defp list_entries(list_id) do
    service_state =
      ShoppingList.SubscriptionService
      |> ShoppingList.Service.Discovery.whereis(list_id)
      |> :sys.get_state()

    ShoppingList.entries(service_state.shopping_list)
  end
end
