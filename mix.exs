defmodule Meeseeks.Mixfile do
  use Mix.Project

  @version "0.4.1"

  def project do
    [app: :meeseeks,
     version: @version,
     elixir: "~> 1.3",
     deps: deps(),

     # Hex
     package: package(),
     description: description(),

     # HexDocs
     name: "Meeseeks",
     source_url: "https://github.com/mischov/meeseeks",
     docs: [main: "Meeseeks"]]
  end

  def application do
    [applications: [:meeseeks_html5ever, :logger, :rustler]]
  end

  defp deps do
    [{:meeseeks_html5ever, "~> 0.4.6"},

     # dev
     {:credo, "~> 0.6.1", only: :dev},
     {:dialyxir, "~> 0.5", only: [:dev], runtime: false},

     # docs
     {:ex_doc, "~> 0.14", only: :docs},
     {:markdown, github: "devinus/markdown", only: :docs}]
  end

  defp description do
    """
    Meeseeks is a library for parsing and extracting data from HTML.
    """
  end

  defp package do
    [maintainers: ["Mischov"],
     licenses: ["MIT"],
     files: ["lib", "src/*.xrl", "mix.exs", "README.md", "LICENSE"],
     links: %{"Github" => "https://github.com/mischov/meeseeks"}]
  end
end
