defmodule ShoppingListWeb.NotificationsChannel do
  use Phoenix.Channel

  def join("notifications:" <> signed_list_id, _payload, socket) do
    list_id = ShoppingListWeb.decode_list_id!(signed_list_id)
    entries = ShoppingList.Service.subscribe(list_id)
    {:ok, %{entries: entries}, socket}
  end

  def handle_info({:shopping_list_event, event}, socket) do
    push(socket, to_string(event.event_name), Map.delete(event, :event_name))
    {:noreply, socket}
  end
  def handle_info(_, socket), do:
    {:noreply, socket}
end
