defmodule ShoppingList.Application do
  @moduledoc false

  use Application


  # -------------------------------------------------------------------
  # Application callbacks
  # -------------------------------------------------------------------

  @impl true
  def start(_type, _args), do:
    Supervisor.start_link(
      [
        ShoppingList.BackendSystem,
        ShoppingListWeb.Endpoint,
      ],
      strategy: :one_for_one
    )

  @doc false
  def config_change(changed, _new, removed) do
    ShoppingListWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
