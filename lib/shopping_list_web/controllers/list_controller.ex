defmodule ShoppingListWeb.ListController do
  @moduledoc false
  use ShoppingListWeb, :controller


  # -------------------------------------------------------------------
  # Action handlers
  # -------------------------------------------------------------------

  def create(conn, _params) do
    list_id = ShoppingList.Service.new_id()

    signed_list_id = ShoppingListWeb.sign_list_id(list_id)
    redirect(conn, to: list_path(conn, :edit, signed_list_id))
  end

  def edit(conn, params), do:
    render(conn, :edit, signed_list_id: Map.fetch!(params, "id"))
end
