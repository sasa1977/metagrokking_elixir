use Mix.Config

use Mix.Config

config :shopping_list, ShoppingListWeb.Endpoint,
  server: true,
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info
