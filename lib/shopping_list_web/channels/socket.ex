defmodule ShoppingListWeb.Socket do
  use Phoenix.Socket

  ## Channels
  channel "notifications:*", ShoppingListWeb.NotificationsChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
