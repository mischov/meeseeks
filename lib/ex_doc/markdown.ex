# Inspired by the similar solution in Pow (https://github.com/danschultzer/pow)
if Code.ensure_loaded?(ExDoc.Markdown.Earmark) do
  # Due to how relative links works in ExDoc, it's necessary for us to use a
  # custom markdown parser to ensure that paths will work in generated docs.
  #
  # Ref: https://github.com/elixir-lang/ex_doc/issues/889

  defmodule ExDoc.Markdown.Meeseeks do
    @moduledoc false

    alias ExDoc.Markdown.Earmark

    @behaviour ExDoc.Markdown

    def to_ast(text, opts) do
      text
      |> rewrite_urls()
      |> Earmark.to_ast(opts)
    end

    @markdown_link_regex ~r/(\[[\S ]*\]\()([\S]*?)(\.md)([\S]*?\))/

    defp rewrite_urls(text) do
      Regex.replace(@markdown_link_regex, text, &rewrite_url/5)
    end

    # Links to guides in README
    defp rewrite_url(_, first, "guides/" <> guide, ".md", last) do
      first <> "#{guide}.html" <> last
    end

    # Links to CONTRIBUTING.md in README
    defp rewrite_url(_, first, "CONTRIBUTING", ".md", last) do
      first <> "contributing.html" <> last
    end

    defp rewrite_url(other, _, _, _, _), do: other
  end
end
