defmodule ShoppingList.Service do
  @moduledoc "Interface for working with a single shopping list service."

  use GenServer, start: {__MODULE__, :start_link, []}
  alias ShoppingList.{Entry, Service.Discovery, Storage}


  # -------------------------------------------------------------------
  # API
  # -------------------------------------------------------------------

  @doc """
  Stops the shopping list service.

  This is a blocking operation - the function returns once the service has been stopped.
  """
  @spec stop(ShoppingList.id) :: :ok
  def stop(shopping_list_id) do
    case Discovery.whereis(shopping_list_id) do
      nil -> :ok
      pid ->
        Supervisor.terminate_child(ShoppingList.Service.Supervisor, pid)
        :ok
    end
  end

  @doc "Returns the shopping list entries."
  @spec entries(ShoppingList.id) :: [Entry.t]
  def entries(shopping_list_id), do:
    call(shopping_list_id, :entries)

  @doc "Adds an entry to the shopping list."
  @spec add_entry(ShoppingList.id, Entry.id, Entry.name, Entry.quantity) :: :ok
  def add_entry(shopping_list_id, entry_id, name, quantity), do:
    cast(shopping_list_id, {:add_entry, entry_id, name, quantity})

  @doc "Updates the quantity of an entry in the shopping list."
  @spec update_entry_quantity(ShoppingList.id, Entry.id, Entry.quantity) :: :ok | {:error, atom}
  def update_entry_quantity(shopping_list_id, entry_id, new_quantity), do:
    cast(shopping_list_id, {:update_entry_quantity, entry_id, new_quantity})

  @doc "Deletes an entry in the shopping list."
  @spec delete_entry(ShoppingList.id, Entry.id) :: :ok
  def delete_entry(shopping_list_id, entry_id), do:
    cast(shopping_list_id, {:delete_entry, entry_id})


  # -------------------------------------------------------------------
  # GenServer callbacks
  # -------------------------------------------------------------------

  @impl true
  def init(shopping_list_id) do
    Process.flag(:trap_exit, true)
    events = Storage.events(shopping_list_id)
    shopping_list = ShoppingList.new(shopping_list_id, events)
    {:ok, shopping_list}
  end

  @impl true
  def handle_call(:entries, _from, shopping_list), do:
    {:reply, ShoppingList.entries(shopping_list), shopping_list}

  @impl true
  def handle_cast({:add_entry, entry_id, name, quantity}, shopping_list), do:
    apply_event(shopping_list, ShoppingList.entry_added(entry_id, name, quantity))

  def handle_cast({:update_entry_quantity, entry_id, quantity}, shopping_list), do:
    apply_event(shopping_list, ShoppingList.entry_quantity_updated(entry_id, quantity))

  def handle_cast({:delete_entry, entry_id}, shopping_list), do:
    apply_event(shopping_list, ShoppingList.entry_deleted(entry_id))


  # -------------------------------------------------------------------
  # Internal functions
  # -------------------------------------------------------------------

  defp call(shopping_list_id, message) do
    ensure_started(shopping_list_id)
    GenServer.call(Discovery.name(shopping_list_id), message)
  end

  defp cast(shopping_list_id, message) do
    ensure_started(shopping_list_id)
    GenServer.cast(Discovery.name(shopping_list_id), message)
  end

  defp ensure_started(shopping_list_id) do
    if Discovery.whereis(shopping_list_id) == nil do
      case ShoppingList.Service.Supervisor.start_service(shopping_list_id) do
        {:ok, _pid} -> :ok
        {:error, {:already_started, _pid}} -> :ok
      end
    end
  end

  defp apply_event(shopping_list, event) do
    new_shopping_list = ShoppingList.apply_event(shopping_list, event)
    Storage.store_event!(ShoppingList.id(shopping_list), event)
    {:noreply, new_shopping_list}
  end


  # -------------------------------------------------------------------
  # Supervision tree
  # -------------------------------------------------------------------

  @doc false
  def start_link(shopping_list_id), do:
    GenServer.start_link(__MODULE__, shopping_list_id, name: Discovery.name(shopping_list_id))
end
