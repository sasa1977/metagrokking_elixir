defmodule Mix.Tasks.ShoppingList.Release do
  @shortdoc "Creates the shopping list release."
  @moduledoc false

  # Mix.Task behaviour is not in PLT since Mix is not a runtime dep, so we disable the warning
  @dialyzer :no_undefined_callbacks

  use Mix.Task

  def run(_args) do
    [
      "shopping_list.build_assets",
      "phx.digest",
      "release"
    ]
    |> Enum.each(&Mix.Task.run/1)
  end
end
