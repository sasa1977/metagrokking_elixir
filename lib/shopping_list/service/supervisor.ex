defmodule ShoppingList.Service.Supervisor do
  @moduledoc "Supervisor of shopping list services."


  # -------------------------------------------------------------------
  # API
  # -------------------------------------------------------------------

  @doc "Starts the process."
  @spec start_link() :: Supervisor.on_start
  def start_link(), do:
    Supervisor.start_link(
      [ShoppingList.Service],
      name: __MODULE__,
      strategy: :simple_one_for_one
    )

  @doc "Starts the shopping list service."
  @spec start_service() :: Supervisor.on_start_child
  def start_service(), do:
    Supervisor.start_child(__MODULE__, [])
end
