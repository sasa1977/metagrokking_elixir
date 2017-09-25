use Mix.Config

config :shopping_list, ShoppingListWeb.Endpoint,
  http: [acceptors: 10]

config :shopping_list, ShoppingListWeb.Endpoint,
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin", cd: Path.expand("../assets", __DIR__)]]

config :shopping_list, ShoppingListWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{lib/shopping_list_web/views/.*(ex)$},
      ~r{lib/shopping_list_web/templates/.*(eex)$}
    ]
  ]

config :phoenix, :stacktrace_depth, 20
