defmodule Meeseeks.CSS do
  @moduledoc """
  Compile CSS selector syntax into `Meeseeks.Selector`s.

  ## Supported Syntax

  | Pattern | Example | Notes |
  | --- | --- | --- |
  | **Basic Selectors** | --- | --- |
  | `*` | `*` | Matches any for `ns` or `tag` |
  | `tag` | `div` | |
  | `ns|tag` | `<foo:div>` | |
  | `#id` | `div#bar`, `#bar` | |
  | `.class` | `div.baz`, `.baz` | |
  | `[attr]` | `a[href]`, `[lang]` | |
  | `[^attrPrefix]` | `div[^data-]` | |
  | `[attr=val]` | `a[rel="nofollow"]` | |
  | `[attr~=valIncludes]` | `div[things~=thing1]` | |
  | `[attr|=valDash]` | `p[lang|=en]` | |
  | `[attr^=valPrefix]` | `a[href^=https:]` | |
  | `[attr$=valSuffix]` | `img[src$=".png"]` | |
  | `[attr*=valContaining]` | `a[href*=admin]` | |
  | &#8203; | | |
  | **Pseudo Classes** | --- | --- |
  | `:first-child` | `li:first-child` | |
  | `:first-of-type` | `li:first-of-type` | |
  | `:last-child` | `tr:last-child` | |
  | `:last-of-type` | `tr:last-of-type` | |
  | `:not` | `not(p:nth-child(even))` | Selectors cannot contain combinators or the `not` pseudo class |
  | `:nth-child(n)` | `p:nth-child(even)` | Supports even, odd, 1.., or *a*n+*b* formulas |
  | `:nth-last-child(n)` | `p:nth-last-child(2)` | Supports even, odd, 1.., or *a*n+*b* formulas |
  | `:nth-last-of-type(n)` | `p:nth-last-of-type(2n+1)` | Supports even, odd, 1.., or *a*n+*b* formulas |
  | `:nth-of-type(n)` | `p:nth-of-type(1)` | Supports even, odd, 1.., or *a*n+*b* formulas |
  | &#8203; | | |
  | **Combinators** | --- | --- |
  | `X Y` | `div.header .logo` | `Y` descendant of `X` |
  | `X > Y` | `ol > li` | `Y` child of `X` |
  | `X + Y` | `div + p` | `Y` is sibling directly after `X` |
  | `X ~ Y` | `div ~ p` | `Y` is any sibling after `X` |
  | `X, Y, Z` | `button.standard, button.alert` | Matches `X`, `Y`, or `Z` |

  ## Examples

      iex> import Meeseeks.CSS
      iex> css("a[href^=\\"https://\\"]")
      %Meeseeks.Selector.Element{
        combinator: nil,
        selectors: [
          %Meeseeks.Selector.Element.Tag{value: "a"},
          %Meeseeks.Selector.Element.Attribute.ValuePrefix{
            attribute: "href",
            value: "https://"}]}
      iex> css("ul, ol")
      [%Meeseeks.Selector.Element{
          combinator: nil,
          selectors: [%Meeseeks.Selector.Element.Tag{value: "ul"}]},
       %Meeseeks.Selector.Element{
         combinator: nil,
         selectors: [%Meeseeks.Selector.Element.Tag{value: "ol"}]}]
  """

  alias Meeseeks.Selector.CSS

  @doc """
  Compiles a string representing CSS selector syntax into one or more
  `Meeseeks.Selector`s.

  When the string is static this work will be done during Elixir's
  compilation, but if the string interpolates values the work will
  occur at runtime.
  """

  defmacro css(string) when is_binary(string) do
    string
    |> CSS.compile_selectors()
    |> Macro.escape()
  end

  defmacro css({:<<>>, _meta, _pieces} = interpolated_string) do
    quote do: CSS.compile_selectors(unquote(interpolated_string))
  end

  defmacro css({:<>, _meta, _pieces} = interpolated_string) do
    quote do: CSS.compile_selectors(unquote(interpolated_string))
  end
end
