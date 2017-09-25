defmodule ShoppingListWeb.ListControllerTest do
  use ShoppingListWeb.ConnCase, async: false


  # -------------------------------------------------------------------
  # Tests
  # -------------------------------------------------------------------

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ShoppingList.EctoRepo)
    Ecto.Adapters.SQL.Sandbox.mode(ShoppingList.EctoRepo, {:shared, self()})
    :ok
  end

  test "visiting the root page", %{conn: conn} do
    conn = get(conn, "/")
    assert redirected_to(conn)
  end

  test "editing a list", %{conn: conn} do
    conn = get(conn, "/")
    conn = conn |> recycle() |> get(redirected_to(conn))

    assert html_response(conn, 200)
  end
end
