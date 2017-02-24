defmodule Meeseeks.Document.Data do
  @moduledoc false

  alias Meeseeks.Document
  alias Meeseeks.Document.Data

  @enforce_keys [:id]
  defstruct(
    parent: nil,
    id: nil,
    content: ""
  )

  @type t :: %Data{parent: Document.node_id | nil,
                   id: Document.node_id,
                   content: String.t}
end
