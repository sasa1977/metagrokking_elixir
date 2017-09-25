Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    default_release: :default,
    default_environment: :prod

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :shopping_list
end

release :shopping_list do
  set version: current_version(:shopping_list)
  set applications: [
    :runtime_tools
  ]
end
