defmodule Meeseeks.Accumulator.All do
  use Meeseeks.Accumulator
  @moduledoc false

  alias Meeseeks.{Accumulator, Result}

  defstruct values: %{}

  @impl true
  def add(%Accumulator.All{values: values} = acc, document, id) do
    result = %Result{document: document, id: id}
    %{acc | values: Map.put(values, id, result)}
  end

  @impl true
  def return(%Accumulator.All{values: values}) do
    Map.values(values)
    |> Enum.sort(&(&1.id <= &2.id))
  end
end
