defmodule ShoppingList.Service do
  @moduledoc "Interface for working with a single shopping list service."

  use GenServer, start: {__MODULE__, :start_link, []}, restart: :temporary
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

  @doc "Subscribes the calling process to the shopping list notifications."
  @spec subscribe(ShoppingList.id) :: [Entry.t]
  def subscribe(shopping_list_id) do
    ensure_started(shopping_list_id)
    call(shopping_list_id, {:subscribe, self()})
  end

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
    events = Storage.events(shopping_list_id)
    shopping_list = ShoppingList.new(shopping_list_id, events)
    subscribers = new_subscribers()
    {:ok, %{shopping_list: shopping_list, subscribers: subscribers}}
  end

  @impl true
  def handle_call({:subscribe, subscriber}, _from, state), do:
    {
      :reply,
      ShoppingList.entries(state.shopping_list),
      update_in(state.subscribers, &add_subscriber(&1, subscriber))
    }

  def handle_call({:add_entry, entry_id, name, quantity}, _from, state), do:
    apply_event(state, ShoppingList.entry_added(entry_id, name, quantity))

  def handle_call({:update_entry_quantity, entry_id, quantity}, _from, state), do:
    apply_event(state, ShoppingList.entry_quantity_updated(entry_id, quantity))

  def handle_call({:delete_entry, entry_id}, _from, state), do:
    apply_event(state, ShoppingList.entry_deleted(entry_id))

  @impl true
  def handle_info({:EXIT, subscriber, _reason}, state) do
    new_state = update_in(state.subscribers, &remove_subscriber(&1, subscriber))
    if no_subscribers?(new_state.subscribers) do
      {:stop, :normal, new_state}
    else
      {:noreply, new_state}
    end
  end

  def handle_info(other, state), do:
    super(other, state)


  # -------------------------------------------------------------------
  # Internal functions
  # -------------------------------------------------------------------

  defp call(shopping_list_id, message), do:
    GenServer.call(Discovery.name(shopping_list_id), message)

  defp ensure_started(shopping_list_id) do
    if Discovery.whereis(shopping_list_id) == nil do
      case ShoppingList.Service.Supervisor.start_service(shopping_list_id) do
        {:ok, _pid} -> :ok
        {:error, {:already_started, _pid}} -> :ok
      end
    end
  end

  defp apply_event(state, event) do
    new_shopping_list = ShoppingList.apply_event(state.shopping_list, event)
    Storage.store_event!(ShoppingList.id(state.shopping_list), event)
    notify_subscribers(state.subscribers, event)
    {:reply, :ok, %{state | shopping_list: new_shopping_list}}
  end


  # -------------------------------------------------------------------
  # Subscribers management
  # -------------------------------------------------------------------

  defp new_subscribers(), do:
    []

  defp no_subscribers?([]), do: true
  defp no_subscribers?(_), do: false

  defp add_subscriber(subscribers, subscriber) do
    Process.link(subscriber)
    [subscriber | subscribers]
  end

  def remove_subscriber(subscribers, subscriber), do:
    Enum.reject(subscribers, &(&1 == subscriber))

  defp notify_subscribers(subscribers, event), do:
    Enum.each(subscribers, &send(&1, {:shopping_list_event, event}))


  # -------------------------------------------------------------------
  # Supervision tree
  # -------------------------------------------------------------------

  @doc false
  def start_link(shopping_list_id), do:
    GenServer.start_link(__MODULE__, shopping_list_id, name: Discovery.name(shopping_list_id))
end
