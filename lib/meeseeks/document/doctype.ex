defmodule Meeseeks.Document.Doctype do
  @moduledoc false

  @enforce_keys [:id]
  defstruct parent: nil, id: nil, name: "", public: "", system: ""
end
