defmodule Meeseeks.Document.ProcessingInstruction do
  @moduledoc false

  @enforce_keys [:id]
  defstruct parent: nil, id: nil, target: "", data: ""
end
