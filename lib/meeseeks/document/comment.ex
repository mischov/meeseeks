defmodule Meeseeks.Document.Comment do
  @moduledoc false

  @enforce_keys [:id]
  defstruct parent: nil, id: nil, content: ""
end
