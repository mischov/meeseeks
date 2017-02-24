defmodule Meeseeks.Selector.Combinator do
  @moduledoc false

  alias Meeseeks.Selector
  alias Meeseeks.Selector.Combinator

  defstruct(
    match: nil,
    selector: nil
  )

  @type match :: :child | :next_sibling | :next_siblings | :descendant
  @type t :: %Combinator{match: match | nil,
                         selector: Selector.t | nil}
end
