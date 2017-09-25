defmodule ShoppingList.SubscriptionService do
  @moduledoc "Service for managing subscribers to the shopping list."

  use GenServer
  alias ShoppingList.{Entry, Storage}


  # -------------------------------------------------------------------
  # API
  # -------------------------------------------------------------------

  @doc "Subscribes the calling process to the shopping list notifications."
  @spec subscribe(ShoppingList.id) :: [Entry.t]
  def subscribe(shopping_list_id), do:
    call(shopping_list_id, {:subscribe, self()})

  @doc "Prepares the pending event."
  @spec prepare_event(ShoppingList.id, ShoppingList.event) :: :ok
  def prepare_event(shopping_list_id, event), do:
    call(shopping_list_id, {:prepare_event, event})

  @doc "Commits the prepared event."
  @spec commit_event(ShoppingList.id) :: :ok
  def commit_event(shopping_list_id), do:
    cast(shopping_list_id, :commit_event)


  # -------------------------------------------------------------------
  # GenServer callbacks
  # -------------------------------------------------------------------

  @impl true
  def init(shopping_list_id) do
    Process.flag(:trap_exit, true)
    {:ok, %{
      shopping_list_id: shopping_list_id,
      shopping_list: ShoppingList.new(shopping_list_id, Storage.events(shopping_list_id)),
      subscribers: new_subscribers(),
      pending_event: nil,
      pending_shopping_list: nil,
    }}
  end

  @impl true
  def handle_call({:subscribe, subscriber}, _from, state), do:
    {
      :reply,
      ShoppingList.entries(state.shopping_list),
      update_in(state.subscribers, &add_subscriber(&1, subscriber))
    }

  def handle_call({:prepare_event, event}, _from, state), do:
    {:reply, :ok, %{state |
      pending_event: event,
      pending_shopping_list: ShoppingList.apply_event(state.shopping_list, event)
    }}

  @impl true
  def handle_cast(:commit_event, state) do
    false = is_nil(state.pending_event)
    false = is_nil(state.pending_shopping_list)

    notify_subscribers(state.subscribers, state.pending_event)

    {:noreply, %{state |
      shopping_list: state.pending_shopping_list,
      pending_event: nil,
      pending_shopping_list: nil
    }}
  end

  @impl true
  def handle_info({:EXIT, subscriber, _reason}, state) do
    new_state = update_in(state.subscribers, &remove_subscriber(&1, subscriber))
    if no_subscribers?(new_state.subscribers), do:
      ShoppingList.Service.stop_async(ShoppingList.id(state.shopping_list))
    {:noreply, new_state}
  end

  def handle_info(other, state), do:
    super(other, state)


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
  # Internal functions
  # -------------------------------------------------------------------

  defp name(shopping_list_id), do:
    ShoppingList.Service.Discovery.name(__MODULE__, shopping_list_id)

  defp call(shopping_list_id, payload), do:
    GenServer.call(name(shopping_list_id), payload)

  defp cast(shopping_list_id, payload), do:
    GenServer.cast(name(shopping_list_id), payload)


  # -------------------------------------------------------------------
  # Supervision tree
  # -------------------------------------------------------------------

  @doc false
  def start_link(shopping_list_id), do:
    GenServer.start_link(__MODULE__, shopping_list_id, name: name(shopping_list_id))
end
