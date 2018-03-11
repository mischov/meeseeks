defmodule Meeseeks.Selector.XPath.Expr do
  @moduledoc false

  alias Meeseeks.{Context, Document}
  alias Meeseeks.Selector.XPath

  @type t :: struct

  @doc """
  Invoked in order to evaluate the expression struct.
  """
  @callback eval(
              expr :: t,
              node :: Document.node_t(),
              document :: Document.t(),
              context :: Context.t()
            ) :: any

  # eval

  @doc """
  Evaluates the expression struct.
  """
  @spec eval(t, Document.node_t(), Document.t(), Context.t()) :: any
  def eval(%{__struct__: struct} = expr, node, document, context) do
    struct.eval(expr, node, document, context)
  end

  # __using__

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour XPath.Expr

      @impl XPath.Expr
      def eval(_, _, _, _), do: raise("eval/4 not implemented")

      defoverridable XPath.Expr
    end
  end
end
