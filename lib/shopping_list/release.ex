defmodule ShoppingList.Release do
  @moduledoc "Release tasks"

  @doc "Runs all migrations on the production database."
  def migrate do
    Enum.each(
      [:crypto, :ssl, :postgrex, :ecto, :logger],
      &Application.ensure_all_started/1
    )

    :ok = Application.load(:shopping_list)

    {:ok, _} = ShoppingList.EctoRepo.start_link(pool_size: 1)

    Ecto.Migrator.run(
      ShoppingList.EctoRepo,
      Application.app_dir(:shopping_list, "priv/ecto_repo/migrations"),
      :up,
      all: true
    )
  end
end
