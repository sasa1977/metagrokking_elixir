use Mix.Config

config :shopping_list, ShoppingList.EctoRepo,
  adapter: Ecto.Adapters.Postgres,
  database: "shopping_list",
  hostname: "localhost",
  username: "shopping_list",
  password: "shopping_list"

config :shopping_list, ecto_repos: [ShoppingList.EctoRepo]

config :shopping_list, ShoppingListWeb.Endpoint,
  url: [host: "localhost"],
  http: [port: 4000],
  server: true,
  secret_key_base: "8NSNsS69mChhGF7OaPxDP2nKyOz8O0aRbqueh36LjaH7IfoNLEkEvYebvLWplxlF",
  render_errors: [view: ShoppingListWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ShoppingList.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{Mix.env}.exs"
