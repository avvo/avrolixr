defmodule Avrolixr.Mixfile do
  use Mix.Project

  def project do
    [
      app: :avrolixr,
      build_embedded: Mix.env == :prod,
      deps: deps(),
      description: description(),
      dialyzer: [plt_add_deps: :transitive, plt_file: ".local.plt"],
      elixir: "~> 1.3",
      package: package(),
      start_permanent: Mix.env == :prod,
      version: "0.1.3",
   ]
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
      {:erlavro, git: "https://github.com/avvo/erlavro", ref: "fb7c7f0"},
      {:ex_doc, ">= 0.0.0", only: [:dev]},
      {:poison, "~> 2.0"},
    ]
  end

  defp description do
    """
    An Elixir wrapper for the `erlavro` Avro package.
    """
  end

  defp package do
    [
      name: :avrolixr,
      files: ["lib", "mix.exs", "CHANGELOG.md", "README.md", "LICENSE.txt"],
      maintainers: ["Donald Plummer", "John Fearnside"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/avvo/avrolixr",
               "Docs" => "https://hexdocs.pm/avrolixr"}
    ]
  end
end
