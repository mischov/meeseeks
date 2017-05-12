defmodule Meeseeks.XPath do
  @moduledoc """
  Compile XPath 1.0 selector syntax into `Meeseeks.Selector`s.

  ## Supported Syntax

  Supports almost all XPath 1.0 syntax with a few notable exceptions.

  ### No top-level filter expressions

  Due to the way Meeseeks selection works, top-level filter expressions like
  `xpath("(//ol|//ul)[2]")`, which would select the second list element in the
  document, are particularly difficult to implement. An error will be raised
  if you try to use the above or any other top-level filter expression.

  To do the above try something like:

  ```elixir
  Meeseeks.all(doc, xpath("ol|ul")) |> Enum.at(1)
  ```

  All other filter expressions, like `xpath("//div[2]")`, are valid.

  ### No support for variable references

  Variable references are not currently supported, meaning expression like
  `xpath("*[position()=$p]")` are invalid and will raise an error.

  To do the above try something like:

  ```elixir
  p = 2
  xpath("*[position()=" <> Integer.to_string(p) <> "]")
  ```

  ### No support for id(), lang(), or translate() functions

  These three functions from the core functions library are not currently
  supported. A runtime error will be raised should they attempt to be used.

  ### Namespace prefixes are not resolved to namespace uris

  If you want to find a namespace, search for the namespace prefix of node,
  not the expanded namespace-uri. `xpath("*[namespace-uri()='example']")`,
  not `xpath("*[namespace-uri()='https://example.com/ns']")`

  ### Selecting processing instructions is not supported

  Because html5ever (and HTML5 in general) parses processing instructions as
  comments, selecting processing instructions is not supported.

  If you need to access information from processing instructions, look for
  it in comment nodes.

  ## Examples

      iex> import Meeseeks.XPath
      iex> xpath("//li[last()]")
      %Meeseeks.Selector.Element{
        combinator: %Meeseeks.Selector.Combinator.Children{
          selector: %Meeseeks.Selector.Element{
            combinator: nil,
            filters: [
              %Meeseeks.Selector.XPath.Predicate{e:
                %Meeseeks.Selector.XPath.Expr.Predicate{
                  e: %Meeseeks.Selector.XPath.Expr.Function{
                    args: [],
                    f: :last}}}],
            selectors: [%Meeseeks.Selector.Element.Tag{value: "li"}]}},
        filters: nil,
        selectors: []}
      iex> xpath("//ol|//ul")
      [%Meeseeks.Selector.Element{
         combinator: %Meeseeks.Selector.Combinator.Children{
           selector: %Meeseeks.Selector.Element{
             combinator: nil,
             filters: nil,
             selectors: [%Meeseeks.Selector.Element.Tag{value: "ol"}]}},
         filters: nil,
         selectors: []},
       %Meeseeks.Selector.Element{
          combinator: %Meeseeks.Selector.Combinator.Children{
            selector: %Meeseeks.Selector.Element{
              combinator: nil,
              filters: nil,
              selectors: [%Meeseeks.Selector.Element.Tag{value: "ul"}]}},
          filters: nil,
          selectors: []}]

  """
  alias Meeseeks.Selector.XPath

  @doc """
  Compiles a string representing XPath selector syntax into one or more
  `Meeseeks.Selector`s.

  When the string is static this work will be done during Elixir's
  compilation, but if the string interpolates values the work will
  occur at runtime.
  """

  defmacro xpath(string) when is_binary(string) do
    string
    |> XPath.compile_selectors()
    |> Macro.escape()
  end

  defmacro xpath({:<<>>, _meta, _pieces} = interpolated_string) do
    quote do: XPath.compile_selectors(unquote(interpolated_string))
  end

  defmacro xpath({:<>, _meta, _pieces} = interpolated_string) do
    quote do: XPath.compile_selectors(unquote(interpolated_string))
  end
end
