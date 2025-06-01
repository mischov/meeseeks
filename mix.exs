defmodule Meeseeks.Mixfile do
  use Mix.Project

  @description """
  Meeseeks is a library for parsing and extracting data from HTML and XML
  with CSS or XPath selectors.
  """

  @source_url "https://github.com/mischov/meeseeks"
  @version "0.18.0"

  def project do
    [
      app: :meeseeks,
      version: @version,
      elixir: "~> 1.7",
      compilers: compilers(),
      deps: deps(),

      # Hex
      description: @description,
      package: package(),

      # HexDocs
      name: "Meeseeks",
      docs: docs()
    ]
  end

  def application do
    [extra_applications: [:logger, :xmerl]]
  end

  defp compilers do
    [:leex, :yecc] ++ Mix.compilers()
  end

  defp deps do
    [
      {:meeseeks_html5ever, "~> 0.15.0"},

      # Dev
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},

      # Docs
      {:ex_doc, "~> 0.24.0", only: :docs, runtime: false}
    ]
  end

  defp docs do
    [
      markdown_processor: ExDoc.Markdown.Meeseeks,
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"],
      main: "readme",
      extras: [
        "README.md": [],
        "CHANGELOG.md": [],
        "CONTRIBUTING.md": [],
        "guides/meeseeks_vs_floki.md": [],
        "guides/css_selectors.md": [],
        "guides/xpath_selectors.md": [],
        "guides/custom_selectors.md": [],
        "guides/deployment.md": []
      ],
      groups_for_extras: [
        Guides: Path.wildcard("guides/*.md")
      ]
    ]
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
      links: %{"GitHub" => @source_url}
    ]
  end
end
