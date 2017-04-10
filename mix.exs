defmodule Meeseeks.Mixfile do
  use Mix.Project

  @version "0.4.0"

  def project do
    [app: :meeseeks,
     name: "Meeseeks",
     version: @version,
     description: description(),
     elixir: "~> 1.3",
     package: package(),
     deps: deps(),
     source_url: "https://github.com/mischov/meeseeks",
     docs: [main: "Meeseeks"]]
  end

  def application do
    [applications: [:meeseeks_html5ever, :logger, :rustler]]
  end

  defp deps do
    [{:meeseeks_html5ever, "~> 0.4.4"},

     # dev
     {:credo, "~> 0.6.1", only: :dev},
     {:dialyxir, "~> 0.5", only: [:dev], runtime: false},

     # docs
     {:ex_doc, "~> 0.14", only: :docs},
     {:markdown, github: "devinus/markdown", only: :docs}]
  end

  defp description do
    """
    Meeseeks is a library for extracting data from HTML.
    """
  end

  defp package do
    [maintainers: ["Mischov"],
     licenses: ["MIT"],
     files: ["lib", "src/*.xrl", "mix.exs", "README.md", "LICENSE"],
     links: %{"Github" => "https://github.com/mischov/meeseeks",
              "Docs" => "https://hexdocs.pm/meeseeks"}]
  end
end
