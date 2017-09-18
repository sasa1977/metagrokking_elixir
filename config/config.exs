use Mix.Config

config :shopping_list, ShoppingList.EctoRepo,
  adapter: Ecto.Adapters.Postgres,
  database: "shopping_list",
  hostname: "localhost",
  username: "shopping_list",
  password: "shopping_list"

config :shopping_list, ecto_repos: [ShoppingList.EctoRepo]

import_config "#{Mix.env}.exs"
