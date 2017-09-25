defmodule ShoppingListWeb.EntryController do
  alias ShoppingList.Service

  @moduledoc false
  use ShoppingListWeb, :controller


  # -------------------------------------------------------------------
  # Action handlers
  # -------------------------------------------------------------------

  def create(conn, params) do
    %{"list_id" => signed_list_id, "id" => entry_id, "name" => name, "quantity" => quantity} = params
    list_id = ShoppingListWeb.decode_list_id!(signed_list_id)

    Service.add_entry(list_id, entry_id, name, quantity)

    send_resp(conn, Plug.Conn.Status.code(:ok), "")
  end

  def update(conn, params) do
    %{"list_id" => signed_list_id, "id" => entry_id, "quantity" => quantity} = params
    list_id = ShoppingListWeb.decode_list_id!(signed_list_id)

    Service.update_entry_quantity(list_id, entry_id, quantity)

    send_resp(conn, Plug.Conn.Status.code(:ok), "")
  end

  def delete(conn, params) do
    %{"list_id" => signed_list_id, "id" => entry_id} = params
    list_id = ShoppingListWeb.decode_list_id!(signed_list_id)

    Service.delete_entry(list_id, entry_id)

    send_resp(conn, Plug.Conn.Status.code(:ok), "")
  end
end
