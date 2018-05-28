defmodule MIME.Mixfile do
  use Mix.Project

  @version "1.3.0"

  def project do
    [
      app: :mime,
      version: @version,
      elixir: "~> 1.3",
      description: "A MIME type module for Elixir",
      package: package(),
      deps: deps(),
      aliases: [test: "test --no-start"],
      docs: [
        source_ref: "v#{@version}",
        main: "MIME",
        source_url: "https://github.com/elixir-lang/mime"
      ]
    ]
  end

  def package do
    [
      maintainers: ["alirz23", "José Valim"],
      licenses: ["Apache 2"],
      links: %{"GitHub" => "https://github.com/elixir-lang/mime"}
    ]
  end

  def application do
    [
      mod: {MIME.Application, []},
      env: [types: %{}],
      applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.11", only: :docs},
      {:earmark, ">= 0.0.0", only: :docs}
    ]
  end
end
