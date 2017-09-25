defmodule ShoppingList.Mixfile do
  use Mix.Project

  def project do
    [
      app: :shopping_list,
      version: "0.1.0",
      elixir: "~> 1.5.0",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix] ++ Mix.compilers,
      deps: deps(),
      preferred_cli_env: ["shopping_list.release": :prod],
      dialyzer: [remove_defaults: [:unknown]]
    ]
  end

  def application do
    [extra_applications: [:logger, :runtime_tools], mod: {ShoppingList.Application, []}]
  end

  defp deps do
    [
      {:ecto, "~> 2.2.3"},
      {:postgrex, "~> 0.13.0"},
      {:poison, "~> 3.0"},
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.10"},
      {:cowboy, "~> 1.0"},
      {:distillery, "~> 1.4.0", runtime: false},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:dialyxir, "~> 0.5.0", runtime: false},
      {:ex_doc, "~> 0.16.0", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
