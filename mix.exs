defmodule MIME.Mixfile do
  use Mix.Project

  @version "1.6.0"

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
        source_url: "https://github.com/elixir-plug/mime"
      ]
    ]
  end

  def package do
    [
      maintainers: ["alirz23", "José Valim"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/elixir-plug/mime"}
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
      {:ex_doc, "~> 0.19", only: :docs}
    ]
  end
end
