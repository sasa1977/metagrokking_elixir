defmodule ShoppingList.Mixfile do
  use Mix.Project

  def project do
    [
      app: :shopping_list,
      version: "0.1.0",
      elixir: "~> 1.5.0",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger], mod: {ShoppingList.Application, []}]
  end

  defp deps do
    [
      {:ecto, "~> 2.2.3"},
      {:postgrex, "~> 0.13.0"},
      {:poison, "~> 3.0"},
      {:dialyxir, "~> 0.5.0", runtime: false},
      {:ex_doc, "~> 0.16.0", only: :dev, runtime: false}
    ]
  end
end
