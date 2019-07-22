defmodule Meeseeks.Mixfile do
  use Mix.Project

  @version "0.11.2"

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
      docs: docs()
    ]
  end

  def application do
    [applications: [:logger, :meeseeks_html5ever, :rustler, :xmerl]]
  end

  defp deps do
    [
      {:meeseeks_html5ever, "~> 0.11.1"},

      # dev
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},

      # docs
      {:ex_doc, ex_doc_version(), only: :docs, runtime: false}
    ]
  end

  defp ex_doc_version do
    if System.version() >= "1.7", do: "~> 0.19.0", else: "~> 0.18.0"
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

  defp docs do
    [main: "Meeseeks"]
  end
end
