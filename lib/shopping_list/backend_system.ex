defmodule ShoppingList.BackendSystem do
  @moduledoc "Top-level process for the backend system."


  # -------------------------------------------------------------------
  # API
  # -------------------------------------------------------------------

  @doc "Starts the shopping list backend system."
  @spec start_link() :: Supervisor.on_start
  def start_link(), do:
    Supervisor.start_link(
      [
        ShoppingList.Service.Discovery,
        ShoppingList.Service.Supervisor
      ],
      strategy: :rest_for_one,
      name: __MODULE__
    )
end
