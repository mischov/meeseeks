defmodule Meeseeks.Mixfile do
  use Mix.Project

  @version "0.16.1"

  def project do
    [
      app: :meeseeks,
      version: @version,
      elixir: "~> 1.7",
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
        "LICENSE.md",
        "LICENSE-APACHE.md"
      ],
      links: %{"GitHub" => "https://github.com/mischov/meeseeks"}
    ]
  end

  defp docs do
    [
      markdown_processor: ExDoc.Markdown.Meeseeks,
      source_ref: "v#{@version}",
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
end
