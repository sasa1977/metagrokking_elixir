defmodule ShoppingList.Service do
  @moduledoc "Interface for working with a single shopping list service."

  alias ShoppingList.{Entry, SubscriptionService, CommandService, Service.Discovery}


  # -------------------------------------------------------------------
  # API
  # -------------------------------------------------------------------

  @doc "Creates the unique shopping list id."
  @spec new_id() :: ShoppingList.id
  defdelegate new_id(), to: ShoppingList

  @doc """
  Stops the shopping list service.

  This is a blocking operation - the function returns once the service has been stopped.
  """
  @spec stop(ShoppingList.id) :: :ok
  def stop(shopping_list_id) do
    case Discovery.whereis(__MODULE__, shopping_list_id) do
      nil -> :ok
      pid ->
        Supervisor.terminate_child(ShoppingList.Service.Supervisor, pid)
        :ok
    end
  end

  @doc "Asynchronously stops the shopping list service."
  @spec stop_async(ShoppingList.id) :: :ok
  def stop_async(shopping_list_id) do
    Task.start_link(fn -> stop(shopping_list_id) end)
    :ok
  end

  @doc "Subscribes the calling process to the shopping list notifications."
  @spec subscribe(ShoppingList.id) :: [Entry.t]
  def subscribe(shopping_list_id) do
    ensure_started(shopping_list_id)
    SubscriptionService.subscribe(shopping_list_id)
  end

  @doc "Adds an entry to the shopping list."
  @spec add_entry(ShoppingList.id, Entry.id, Entry.name, Entry.quantity) :: :ok
  defdelegate(add_entry(shopping_list_id, entry_id, name, quantity), to: CommandService)

  @doc "Updates the quantity of an entry in the shopping list."
  @spec update_entry_quantity(ShoppingList.id, Entry.id, Entry.quantity) :: :ok
  defdelegate(update_entry_quantity(shopping_list_id, entry_id, new_quantity), to: CommandService)

  @doc "Deletes an entry in the shopping list."
  @spec delete_entry(ShoppingList.id, Entry.id) :: :ok
  defdelegate(delete_entry(shopping_list_id, entry_id), to: CommandService)


  # -------------------------------------------------------------------
  # Internal functions
  # -------------------------------------------------------------------

  defp ensure_started(shopping_list_id) do
    if Discovery.whereis(__MODULE__, shopping_list_id) == nil do
      case ShoppingList.Service.Supervisor.start_service(shopping_list_id) do
        {:ok, _pid} -> :ok
        {:error, {:already_started, _pid}} -> :ok
      end
    end
  end


  # -------------------------------------------------------------------
  # Supervision tree
  # -------------------------------------------------------------------

  @doc false
  def start_link(shopping_list_id), do:
    Supervisor.start_link(
      [
        {SubscriptionService, shopping_list_id},
        {CommandService, shopping_list_id}
      ],
      strategy: :rest_for_one,
      max_restarts: 100,
      name: Discovery.name(__MODULE__, shopping_list_id)
    )

  @doc false
  def child_spec(_arg), do:
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      restart: :temporary,
      shutdown: 5000,
      type: :supervisor
    }
end
