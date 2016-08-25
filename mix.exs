defmodule Avrolixr.Mixfile do
  use Mix.Project

  def project do
    [app: :avrolixr,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     dialyzer: [plt_add_deps: :transitive, plt_file: ".local.plt"],
     deps: deps()]
  end

  def application do
    [
      mod: {Avrolixr, []},
      applications: [
        :erlavro,
        :mochijson3,
        :poison,
      ],
   ]
  end

  defp deps do
    [
      {:dialyxir, "~> 0.3.5", only: [:dev]},
      {:erlavro, git: "https://github.com/avvo/erlavro"},
      {:poison, "~> 2.0"},
    ]
  end

  def description do
    """
    An Elixir wrapper for the `erlavro` Avro package.
    """
  end

  def package do
    [
      name: :avrolixr,
      files: ["lib", "mix.exs", "CHANGELOG.md", "README.md", "LICENSE.txt"],
      maintainers: ["Donald Plummer", "John Fearnside"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/avvo/avrolixr",
               "Docs" => "https://github.com/avvo/avrolixr"}
    ]
  end
end
