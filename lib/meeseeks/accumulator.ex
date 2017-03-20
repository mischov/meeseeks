defmodule Meeseeks.Accumulator do
  @moduledoc false

  alias Meeseeks.{Document, Result}
  alias Meeseeks.Accumulator.{All, One}

  @spec add(One.t, Document.t, Document.node_id) :: One.t
  @spec add(All.t, Document.t, Document.node_id) :: All.t

  def add(%One{value: nil} = acc, document, id) do
    result = %Result{document: document, id: id}
    %{acc | value: result}
  end

  def add(%All{values: values} = acc, document, id) do
    result = %Result{document: document, id: id}
    %{acc | values: Map.put(values, id, result)}
  end

  @spec return(One.t) :: Result.t | nil
  @spec return(All.t) :: [Result.t]

  def return(%One{value: value}), do: value
  def return(%All{values: values}), do: Map.values(values)
end
