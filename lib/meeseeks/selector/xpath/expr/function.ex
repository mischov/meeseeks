defmodule Meeseeks.Selector.XPath.Expr.Function do
  use Meeseeks.Selector.XPath.Expr
  @moduledoc false

  alias Meeseeks.{Context, Document}
  alias Meeseeks.Selector.XPath.Expr

  defstruct f: nil, args: []

  @nodes Context.nodes_key()

  @impl true
  def eval(expr, node, document, context)

  # last

  def eval(%Expr.Function{f: :last, args: []}, _node, _document, context) do
    context
    |> Map.fetch!(@nodes)
    |> Enum.count()
  end

  def eval(%Expr.Function{f: :last, args: args}, _node, _document, _context) do
    raise invalid_args("last", args)
  end

  # position

  def eval(%Expr.Function{f: :position, args: []}, node, _document, context) do
    Expr.Helpers.position(node, context)
  end

  def eval(%Expr.Function{f: :position, args: args}, _node, _document, _context) do
    raise invalid_args("position", args)
  end

  # count

  def eval(%Expr.Function{f: :count, args: [e]}, node, document, context) do
    v = Expr.eval(e, node, document, context)

    if Expr.Helpers.nodes?(v) do
      Enum.count(v)
    else
      raise invalid_evaluated_args("count", [v])
    end
  end

  def eval(%Expr.Function{f: :count, args: args}, _node, _document, _context) do
    raise invalid_args("count", args)
  end

  # id not supported, if added would involve id attribute

  # local-name

  def eval(%Expr.Function{f: :"local-name", args: []}, node, _document, _context) do
    local_name(node)
  end

  def eval(%Expr.Function{f: :"local-name", args: [e]}, node, document, context) do
    v = Expr.eval(e, node, document, context)

    if Expr.Helpers.nodes?(v) do
      [node | _] = v

      local_name(node)
    else
      raise invalid_evaluated_args("local-name", [v])
    end
  end

  def eval(%Expr.Function{f: :"local-name", args: args}, _node, _document, _context) do
    raise invalid_args("local-name", args)
  end

  # namespace-uri

  ## Currently returns namespace prefix, not full namespace uri.

  def eval(%Expr.Function{f: :"namespace-uri", args: []}, node, _document, _context) do
    namespace_uri(node)
  end

  def eval(%Expr.Function{f: :"namespace-uri", args: [e]}, node, document, context) do
    v = Expr.eval(e, node, document, context)

    if Expr.Helpers.nodes?(v) do
      [node | _] = v

      namespace_uri(node)
    else
      raise invalid_evaluated_args("namespace-uri", [v])
    end
  end

  def eval(%Expr.Function{f: :"namespace-uri", args: args}, _node, _document, _context) do
    raise invalid_args("namespace-uri", args)
  end

  # name

  def eval(%Expr.Function{f: :name, args: []}, node, _document, _context) do
    name(node)
  end

  def eval(%Expr.Function{f: :name, args: [e]}, node, document, context) do
    v = Expr.eval(e, node, document, context)

    if Expr.Helpers.nodes?(v) do
      [node | _] = v

      name(node)
    else
      raise invalid_evaluated_args("name", [v])
    end
  end

  def eval(%Expr.Function{f: :name, args: args}, _node, _document, _context) do
    raise invalid_args("name", args)
  end

  # string

  def eval(%Expr.Function{f: :string, args: []}, node, document, _context) do
    Expr.Helpers.string([node], document)
  end

  def eval(%Expr.Function{f: :string, args: [e]}, node, document, context) do
    Expr.eval(e, node, document, context)
    |> Expr.Helpers.string(document)
  end

  def eval(%Expr.Function{f: :string, args: args}, _node, _document, _context) do
    raise invalid_args("string", args)
  end

  # concat

  def eval(%Expr.Function{f: :concat, args: [_, _ | _] = args}, node, document, context) do
    args
    |> Enum.map(&Expr.eval(&1, node, document, context))
    |> Enum.map(&Expr.Helpers.string(&1, document))
    |> Enum.join("")
  end

  def eval(%Expr.Function{f: :concat, args: args}, _node, _document, _context) do
    raise invalid_args("concat", args)
  end

  # starts-with

  def eval(%Expr.Function{f: :"starts-with", args: [e1, e2]}, node, document, context) do
    v1 =
      Expr.eval(e1, node, document, context)
      |> Expr.Helpers.string(document)

    v2 =
      Expr.eval(e2, node, document, context)
      |> Expr.Helpers.string(document)

    String.starts_with?(v1, v2)
  end

  def eval(%Expr.Function{f: :"starts-with", args: args}, _node, _document, _context) do
    raise invalid_args("starts-with", args)
  end

  # contains

  def eval(%Expr.Function{f: :contains, args: [e1, e2]}, node, document, context) do
    v1 =
      Expr.eval(e1, node, document, context)
      |> Expr.Helpers.string(document)

    v2 =
      Expr.eval(e2, node, document, context)
      |> Expr.Helpers.string(document)

    String.contains?(v1, v2)
  end

  def eval(%Expr.Function{f: :contains, args: args}, _node, _document, _context) do
    raise invalid_args("contains", args)
  end

  # substring-before

  def eval(%Expr.Function{f: :"substring-before", args: [e1, e2]}, node, document, context) do
    v1 =
      Expr.eval(e1, node, document, context)
      |> Expr.Helpers.string(document)

    v2 =
      Expr.eval(e2, node, document, context)
      |> Expr.Helpers.string(document)

    case String.split(v1, v2, parts: 2) do
      [_] -> ""
      [substring_before, _] -> substring_before
    end
  end

  def eval(%Expr.Function{f: :"substring-before", args: args}, _node, _document, _context) do
    raise invalid_args("substring-before", args)
  end

  # substring-after

  def eval(%Expr.Function{f: :"substring-after", args: [e1, e2]}, node, document, context) do
    v1 =
      Expr.eval(e1, node, document, context)
      |> Expr.Helpers.string(document)

    v2 =
      Expr.eval(e2, node, document, context)
      |> Expr.Helpers.string(document)

    case String.split(v1, v2, parts: 2) do
      [_] -> ""
      [_, substring_after] -> substring_after
    end
  end

  def eval(%Expr.Function{f: :"substring-after", args: args}, _node, _document, _context) do
    raise invalid_args("substring-after", args)
  end

  # substring

  def eval(%Expr.Function{f: :substring, args: [e1, e2]}, node, document, context) do
    v1 =
      Expr.eval(e1, node, document, context)
      |> Expr.Helpers.string(document)

    v2 =
      Expr.eval(e2, node, document, context)
      |> Expr.Helpers.number(document)
      |> Expr.Helpers.round_()
      # First index is 1, not 0, so subtract 1
      |> Expr.Helpers.sub(1)

    Expr.Helpers.substring(v1, v2)
  end

  def eval(%Expr.Function{f: :substring, args: [e1, e2, e3]}, node, document, context) do
    v1 =
      Expr.eval(e1, node, document, context)
      |> Expr.Helpers.string(document)

    v2 =
      Expr.eval(e2, node, document, context)
      |> Expr.Helpers.number(document)
      |> Expr.Helpers.round_()
      # First index is 1, not 0, so subtract 1
      |> Expr.Helpers.sub(1)

    v3 =
      Expr.eval(e3, node, document, context)
      |> Expr.Helpers.number(document)
      |> Expr.Helpers.round_()

    Expr.Helpers.substring(v1, v2, v3)
  end

  def eval(%Expr.Function{f: :substring, args: args}, _node, _document, _context) do
    raise invalid_args("substring", args)
  end

  # string-length

  def eval(%Expr.Function{f: :"string-length", args: []}, node, document, _context) do
    [node]
    |> Expr.Helpers.string(document)
    |> String.length()
  end

  def eval(%Expr.Function{f: :"string-length", args: [e]}, node, document, context) do
    Expr.eval(e, node, document, context)
    |> Expr.Helpers.string(document)
    |> String.length()
  end

  def eval(%Expr.Function{f: :"string-length", args: args}, _node, _document, _context) do
    raise invalid_args("string-length", args)
  end

  # normalize-space

  def eval(%Expr.Function{f: :"normalize-space", args: []}, node, document, _context) do
    [node]
    |> Expr.Helpers.string(document)
    |> normalize_whitespace()
  end

  def eval(%Expr.Function{f: :"normalize-space", args: [e]}, node, document, context) do
    Expr.eval(e, node, document, context)
    |> Expr.Helpers.string(document)
    |> normalize_whitespace()
  end

  def eval(%Expr.Function{f: :"normalize-space", args: args}, _node, _document, _context) do
    raise invalid_args("normalize-space", args)
  end

  # translate not supported

  # boolean

  def eval(%Expr.Function{f: :boolean, args: [e]}, node, document, context) do
    Expr.eval(e, node, document, context)
    |> Expr.Helpers.boolean(document)
  end

  def eval(%Expr.Function{f: :boolean, args: args}, _node, _document, _context) do
    raise invalid_args("boolean", args)
  end

  # not

  def eval(%Expr.Function{f: :not, args: [e]}, node, document, context) do
    Expr.eval(e, node, document, context)
    |> Expr.Helpers.boolean(document)
    |> not_()
  end

  def eval(%Expr.Function{f: :not, args: args}, _node, _document, _context) do
    raise invalid_args("not", args)
  end

  # true

  def eval(%Expr.Function{f: true, args: []}, _node, _document, _context) do
    true
  end

  def eval(%Expr.Function{f: true, args: args}, _node, _document, _context) do
    raise invalid_args("true", args)
  end

  # false

  def eval(%Expr.Function{f: false, args: []}, _node, _document, _context) do
    false
  end

  def eval(%Expr.Function{f: false, args: args}, _node, _document, _context) do
    raise invalid_args("false", args)
  end

  # lang not supported

  # number

  def eval(%Expr.Function{f: :number, args: []}, node, document, _context) do
    [node]
    |> Expr.Helpers.number(document)
  end

  def eval(%Expr.Function{f: :number, args: [e]}, node, document, context) do
    Expr.eval(e, node, document, context)
    |> Expr.Helpers.number(document)
  end

  def eval(%Expr.Function{f: :number, args: args}, _node, _document, _context) do
    raise invalid_args("number", args)
  end

  # sum

  def eval(%Expr.Function{f: :sum, args: [e]}, node, document, context) do
    v = Expr.eval(e, node, document, context)

    if Expr.Helpers.nodes?(v) do
      Enum.reduce(v, 0, fn node, sum ->
        node
        |> Expr.Helpers.string(document)
        |> Expr.Helpers.number(document)
        |> Expr.Helpers.add(sum)
      end)
    else
      raise invalid_evaluated_args("sum", [v])
    end
  end

  def eval(%Expr.Function{f: :sum, args: args}, _node, _document, _context) do
    raise invalid_args("sum", args)
  end

  # floor

  def eval(%Expr.Function{f: :floor, args: [e]}, node, document, context) do
    Expr.eval(e, node, document, context)
    |> Expr.Helpers.number(document)
    |> Expr.Helpers.floor()
  end

  def eval(%Expr.Function{f: :floor, args: args}, _node, _document, _context) do
    raise invalid_args("floor", args)
  end

  # ceiling

  def eval(%Expr.Function{f: :ceiling, args: [e]}, node, document, context) do
    Expr.eval(e, node, document, context)
    |> Expr.Helpers.number(document)
    |> Expr.Helpers.ceiling()
  end

  def eval(%Expr.Function{f: :ceiling, args: args}, _node, _document, _context) do
    raise invalid_args("ceiling", args)
  end

  # round

  def eval(%Expr.Function{f: :round, args: [e]}, node, document, context) do
    Expr.eval(e, node, document, context)
    |> Expr.Helpers.number(document)
    |> Expr.Helpers.round_()
  end

  def eval(%Expr.Function{f: :round, args: args}, _node, _document, _context) do
    raise invalid_args("round", args)
  end

  # unknown function

  def eval(%Expr.Function{f: f} = _expr, _node, _document, _context) do
    raise "XPath function #{f} is unknown"
  end

  # helpers

  defp invalid_args(f, args) do
    "Invalid arguments to XPath function #{f}: #{inspect(args)}"
  end

  defp invalid_evaluated_args(f, args) do
    "Invalid evaluated arguments to XPath function #{f}: #{inspect(args)}"
  end

  defp local_name(%Document.Element{tag: local_name}), do: local_name

  defp local_name({attr, _value}) do
    case String.split(attr, ":", parts: 2) do
      [name] -> name
      [_namespace, name] -> name
    end
  end

  defp local_name(namespace) when is_binary(namespace), do: namespace
  defp local_name(_), do: ""

  defp namespace_uri(%Document.Element{namespace: ns_uri}), do: ns_uri

  defp namespace_uri({attr, _value}) do
    case String.split(attr, ":", parts: 2) do
      [_name] -> ""
      [namespace, _name] -> namespace
    end
  end

  defp namespace_uri(_), do: ""

  defp name(%Document.Element{} = element) do
    case [element.namespace, element.tag] do
      ["", ""] -> ""
      ["", local_name] -> local_name
      [ns_uri, local_name] -> ns_uri <> ":" <> local_name
    end
  end

  defp name({attr, _value}), do: attr
  defp name(namespace) when is_binary(namespace), do: namespace
  defp name(_), do: ""

  defp normalize_whitespace(s) do
    s
    |> String.trim()
    |> String.replace(~r/[\s]+/, " ")
  end

  defp not_(b) when is_boolean(b), do: not b
end
