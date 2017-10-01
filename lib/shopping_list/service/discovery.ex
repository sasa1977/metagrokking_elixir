defmodule ShoppingList.Service.Discovery do
  @moduledoc "Discovery of shopping list processes."


  # -------------------------------------------------------------------
  # API
  # -------------------------------------------------------------------

  @doc "Returns the registration name that can be used with OTP processes such as `GenServer`."
  @spec name(ShoppingList.id) :: GenServer.name
  def name(shopping_list_id), do:
    {:via, Registry, {__MODULE__, shopping_list_id}}

  @doc "Returns the pid of the shopping list service process."
  @spec whereis(ShoppingList.id) :: nil | pid
  def whereis(shopping_list_id) do
    case Registry.lookup(__MODULE__, shopping_list_id) do
      [] -> nil
      [{pid, _}] -> if Process.alive?(pid), do: pid, else: nil
    end
  end


  # -------------------------------------------------------------------
  # Supervision tree
  # -------------------------------------------------------------------

  @doc false
  def start_link(), do:
    Registry.start_link(:unique, __MODULE__)

  @doc false
  def child_spec(_arg), do:
    Supervisor.child_spec(Registry, start: {__MODULE__, :start_link, []}, id: __MODULE__)
end
