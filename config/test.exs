use Mix.Config

config :logger, level: :warn

config :shopping_list, ShoppingList.EctoRepo,
  database: "shopping_list_test",
  pool: Ecto.Adapters.SQL.Sandbox

config :shopping_list, ShoppingListWeb.Endpoint,
  http: [port: 4001],
  server: false
