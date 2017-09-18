defmodule ShoppingList.Service do
  @moduledoc "Interface for working with a single shopping list service."

  use GenServer, start: {__MODULE__, :start_link, []}
  alias ShoppingList.{Entry, Service.Discovery}

  @type id :: pos_integer

  # -------------------------------------------------------------------
  # API
  # -------------------------------------------------------------------

  @doc "Returns the shopping list entries."
  @spec entries(id) :: [Entry.t]
  def entries(shopping_list_id), do:
    GenServer.call(
      Discovery.name(shopping_list_id),
      :entries
    )

  @doc "Adds an entry to the shopping list."
  @spec add_entry(id, Entry.name, Entry.quantity) :: :ok
  def add_entry(shopping_list_id, name, quantity), do:
    GenServer.cast(
      Discovery.name(shopping_list_id),
      {:add_entry, name, quantity}
    )

  @doc "Updates the quantity of an entry in the shopping list."
  @spec update_entry_quantity(id, Entry.id, Entry.quantity) :: :ok
  def update_entry_quantity(shopping_list_id, entry_id, new_quantity), do:
    GenServer.cast(
      Discovery.name(shopping_list_id),
      {:update_entry_quantity, entry_id, new_quantity}
    )

  @doc "Deletes an entry in the shopping list."
  @spec delete_entry(id, Entry.id) :: :ok
  def delete_entry(shopping_list_id, entry_id), do:
    GenServer.cast(
      Discovery.name(shopping_list_id),
      {:delete_entry, entry_id}
    )


  # -------------------------------------------------------------------
  # GenServer callbacks
  # -------------------------------------------------------------------

  @impl true
  def init(_arg), do:
    {:ok, ShoppingList.new()}

  @impl true
  def handle_call(:entries, _from, shopping_list), do:
    {:reply, ShoppingList.entries(shopping_list), shopping_list}

  @impl true
  def handle_cast({:add_entry, name, quantity}, shopping_list), do:
    {:noreply, ShoppingList.add_entry(shopping_list, name, quantity)}

  def handle_cast({:update_entry_quantity, entry_id, new_quantity}, shopping_list), do:
    {:noreply, ShoppingList.update_entry_quantity(shopping_list, entry_id, new_quantity)}

  def handle_cast({:delete_entry, entry_id}, shopping_list), do:
    {:noreply, ShoppingList.delete_entry(shopping_list, entry_id)}


  # -------------------------------------------------------------------
  # Supervision tree
  # -------------------------------------------------------------------

  @doc false
  def start_link(shopping_list_id), do:
    GenServer.start_link(__MODULE__, nil, name: Discovery.name(shopping_list_id))
end
