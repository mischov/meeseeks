# Custom Selectors

Meeseeks is designed to have extremely extensible selectors, and creating a custom selector is as easy as defining a struct that implements the [`Meeseeks.Selector`](https://hexdocs.pm/meeseeks/Meeseeks.Selector.html) behaviour.

```elixir
defmodule CommentContainsSelector do
  use Meeseeks.Selector

  alias Meeseeks.Document

  defstruct value: ""

  def match(selector, %Document.Comment{} = node, _document, _context) do
    String.contains?(node.content, selector.value)
  end

  def match(_selector, _node, _document, _context) do
    false
  end
end

selector = %CommentContainsSelector{value: "TODO"}

Meeseeks.one("<!-- TODO: Close vuln! -->", selector)
#=> #Meeseeks.Result<{ <!-- TODO: Close vuln! --> }>
```

To learn more, check the documentation for [`Meeseeks.Selector`](https://hexdocs.pm/meeseeks/Meeseeks.Selector.html) and [`Meeseeks.Selector.Combinator`](https://hexdocs.pm/meeseeks/Meeseeks.Selector.Combinator.html)
