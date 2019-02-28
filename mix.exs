defmodule Meeseeks.Mixfile do
  use Mix.Project

  @version "0.10.1"

  def project do
    [
      app: :meeseeks,
      version: @version,
      elixir: "~> 1.4",
      deps: deps(),

      # Hex
      package: package(),
      description: description(),

      # HexDocs
      name: "Meeseeks",
      source_url: "https://github.com/mischov/meeseeks",
      docs: [main: "Meeseeks"]
    ]
  end

  def application do
    [applications: [:logger, :meeseeks_html5ever, :rustler, :xmerl]]
  end

  defp deps do
    [
      {:meeseeks_html5ever, "~> 0.10.1"},

      # dev
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},

      # docs
      {:ex_doc, "~> 0.14", only: :docs},
      {:markdown, github: "devinus/markdown", only: :docs}
    ]
  end

  defp description do
    """
    Meeseeks is a library for parsing and extracting data from HTML and XML with CSS or XPath selectors.
    """
  end

  defp package do
    [
      maintainers: ["Mischov"],
      licenses: ["MIT"],
      files: [
        "lib",
        "src/*.xrl",
        "src/*.yrl",
        "mix.exs",
        "README.md",
        "LICENSE",
        "LICENSE-APACHE"
      ],
      links: %{"Github" => "https://github.com/mischov/meeseeks"}
    ]
  end
end
