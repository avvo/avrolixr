defmodule Avrolixr.Mixfile do
  use Mix.Project

  def project do
    [
      app: :avrolixr,
      build_embedded: Mix.env == :prod,
      deps: deps(),
      description: description(),
      dialyzer: [plt_add_deps: :transitive, plt_file: ".local.plt"],
      elixir: "~> 1.4",
      package: package(),
      start_permanent: Mix.env == :prod,
      version: "0.4.1"
   ]
  end

  def application do
    [
      mod: {Avrolixr, []},
      applications: [
        :erlavro,
        :mochijson3,
        :poison
      ]
    ]
  end

  defp deps do
    [
      # So that it can be published to Hex
      {:erlavro, git: "https://github.com/avvo/erlavro", ref: "fb7c7f0", only: [:dev]},
      {:poison, "~> 3.1"},

      # NON-PRODUCTION DEPS
      {:dialyxir, "~> 0.4", only: [:dev]},
      {:ex_doc, ">= 0.0.0", only: [:dev]}
    ]
  end

  defp description do
    """
    An Elixir wrapper for the `erlavro` Avro package.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "CHANGELOG.md", "README.md", "LICENSE.txt"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/avvo/avrolixr",
        "Docs" => "https://hexdocs.pm/avrolixr"
      },
      maintainers: ["Donald Plummer", "John Fearnside"],
      name: :avrolixr
    ]
  end
end
