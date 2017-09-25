defmodule ShoppingList.CommandService do
  @moduledoc "Service for handling commands which modify the shopping list."

  use GenServer
  alias ShoppingList.{Entry, Storage}


  # -------------------------------------------------------------------
  # API
  # -------------------------------------------------------------------

  @doc "Adds an entry to the shopping list."
  @spec add_entry(ShoppingList.id, Entry.id, Entry.name, Entry.quantity) :: :ok
  def add_entry(shopping_list_id, entry_id, name, quantity), do:
    call(shopping_list_id, {:add_entry, entry_id, name, quantity})

  @doc "Updates the quantity of an entry in the shopping list."
  @spec update_entry_quantity(ShoppingList.id, Entry.id, Entry.quantity) :: :ok | {:error, atom}
  def update_entry_quantity(shopping_list_id, entry_id, new_quantity), do:
    call(shopping_list_id, {:update_entry_quantity, entry_id, new_quantity})

  @doc "Deletes an entry in the shopping list."
  @spec delete_entry(ShoppingList.id, Entry.id) :: :ok
  def delete_entry(shopping_list_id, entry_id), do:
    call(shopping_list_id, {:delete_entry, entry_id})


  # -------------------------------------------------------------------
  # GenServer callbacks
  # -------------------------------------------------------------------

  @impl true
  def init(shopping_list_id) do
    Process.flag(:trap_exit, true)
    {:ok, shopping_list_id}
  end

  @impl true
  def handle_call({:add_entry, entry_id, name, quantity}, _from, shopping_list_id), do:
    handle_event(shopping_list_id, ShoppingList.entry_added(entry_id, name, quantity))

  def handle_call({:update_entry_quantity, entry_id, quantity}, _from, shopping_list_id), do:
    handle_event(shopping_list_id, ShoppingList.entry_quantity_updated(entry_id, quantity))

  def handle_call({:delete_entry, entry_id}, _from, shopping_list_id), do:
    handle_event(shopping_list_id, ShoppingList.entry_deleted(entry_id))


  # -------------------------------------------------------------------
  # Internal functions
  # -------------------------------------------------------------------

  defp name(shopping_list_id), do:
    ShoppingList.Service.Discovery.name(__MODULE__, shopping_list_id)

  defp call(shopping_list_id, payload), do:
    GenServer.call(name(shopping_list_id), payload)

  defp handle_event(shopping_list_id, event) do
    ShoppingList.SubscriptionService.prepare_event(shopping_list_id, event)
    Storage.store_event!(shopping_list_id, event)
    ShoppingList.SubscriptionService.commit_event(shopping_list_id)

    {:reply, :ok, shopping_list_id}
  end


  # -------------------------------------------------------------------
  # Supervision tree
  # -------------------------------------------------------------------

  @doc false
  def start_link(shopping_list_id), do:
    GenServer.start_link(__MODULE__, shopping_list_id, name: name(shopping_list_id))
end
