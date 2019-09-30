defmodule Meeseeks.Document.Element do
  @moduledoc false

  @enforce_keys [:id]
  defstruct parent: nil, id: nil, namespace: "", tag: "", attributes: [], children: []
end
