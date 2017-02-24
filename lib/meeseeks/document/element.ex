defmodule Meeseeks.Document.Element do
  @moduledoc false

  alias Meeseeks.Document
  alias Meeseeks.Document.Element

  @enforce_keys [:id]
  defstruct(
    parent: nil,
    id: nil,
    namespace: nil,
    tag: "",
    attributes: [],
    children: []
  )

  @type t :: %Element{parent: Document.node_id | nil,
                      id: Document.node_id,
                      namespace: String.t | nil,
                      tag: String.t,
                      attributes: [{String.t, String.t}],
                      children: [Document.node_id]}
end
