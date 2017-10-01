defmodule ShoppingList.Service.Supervisor do
  @moduledoc "Supervisor of shopping list services."


  # -------------------------------------------------------------------
  # API
  # -------------------------------------------------------------------

  @doc "Starts the shopping list service."
  @spec start_service(ShoppingList.id) :: Supervisor.on_start_child
  def start_service(shopping_list_id), do:
    Supervisor.start_child(__MODULE__, [shopping_list_id])


  # -------------------------------------------------------------------
  # Supervision tree
  # -------------------------------------------------------------------

  @doc false
  def start_link(), do:
    Supervisor.start_link(
      [ShoppingList.Service],
      name: __MODULE__,
      strategy: :simple_one_for_one
    )

  @doc false
  def child_spec(_arg), do:
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      restart: :permanent,
      shutdown: 5000,
      type: :supervisor
    }
end
