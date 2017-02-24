defmodule Meeseeks.Document.Text do
  @moduledoc false

  alias Meeseeks.Document
  alias Meeseeks.Document.Text

  @enforce_keys [:id]
  defstruct(
    parent: nil,
    id: nil,
    content: ""
  )

  @type t :: %Text{parent: Document.node_id | nil,
                   id: Document.node_id,
                   content: String.t}
end
