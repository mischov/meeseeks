defmodule Meeseeks.Document.Data do
  @moduledoc false

  @enforce_keys [:id]
  defstruct parent: nil, id: nil, type: nil, content: ""
end
