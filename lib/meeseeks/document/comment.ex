defmodule Meeseeks.Document.Comment do
  @moduledoc false

  alias Meeseeks.Document
  alias Meeseeks.Document.Comment

  @enforce_keys [:id]
  defstruct(
    parent: nil,
    id: nil,
    content: ""
  )

  @type t :: %Comment{parent: Document.node_id | nil,
                      id: Document.node_id,
                      content: String.t}
end
