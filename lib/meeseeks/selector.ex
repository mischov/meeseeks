defmodule Meeseeks.Selector do
  @moduledoc false

  alias Meeseeks.Selector.{Attribute,
                           Combinator,
                           Element,
                           Parser,
                           Pseudo,
                           Tokenizer}

  @type t :: Attribute.t | Combinator.t | Element.t | Pseudo.t

  def parse_selectors(selector_string) do
    selector_string
    |> String.split(", ")
    |> Enum.map(&Tokenizer.tokenize/1)
    |> Enum.map(&Parser.parse_element/1)
  end
end
