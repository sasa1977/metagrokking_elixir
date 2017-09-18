defmodule ShoppingList.Application do
  @moduledoc false

  use Application


  # -------------------------------------------------------------------
  # Application callbacks
  # -------------------------------------------------------------------

  @doc false
  def start(_type, _args), do:
    ShoppingList.BackendSystem.start_link()
end
