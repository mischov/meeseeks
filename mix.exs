defmodule Meeseeks.Mixfile do
  use Mix.Project

  @source_url "https://github.com/mischov/meeseeks"
  @version "0.16.1"

  def project do
    [
      app: :meeseeks,
      version: @version,
      elixir: "~> 1.7",
      deps: deps(),

      # Hex
      package: package(),

      # HexDocs
      name: "Meeseeks",
      docs: docs()
    ]
  end

  def application do
    [extra_applications: [:logger, :xmerl]]
  end

  defp deps do
    [
      {:meeseeks_html5ever, "~> 0.13.1"},

      # dev
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},

      # docs
      {:ex_doc, "~> 0.24.0", only: :docs, runtime: false}
    ]
  end

  defp package do
    [
      description: "Meeseeks is a library for parsing and extracting data " <>
        "from HTML and XML with CSS or XPath selectors.",
      maintainers: ["Mischov"],
      licenses: ["MIT"],
      files: [
        "lib",
        "src/*.xrl",
        "src/*.yrl",
        "mix.exs",
        "README.md",
        "LICENSE.md",
        "LICENSE-APACHE.md"
      ],
      links: %{"GitHub" => @source_url}
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
        "CHANGELOG.md": [],
        "CONTRIBUTING.md": [],
        "README.md": [],
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
end
