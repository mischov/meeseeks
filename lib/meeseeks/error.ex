defmodule Meeseeks.Error do
  @errors %{
    context: [:accumulator_required],
    css_selector: [:invalid, :invalid_input],
    css_selector_parser: [:invalid_input],
    css_selector_tokenizer: [:invalid_input],
    document: [:unknown_node],
    parser: [:invalid_input],
    select: [:no_match, :invalid_selectors],
    xpath_expression: [:invalid_arguments, :invalid_evaluated_arguments],
    xpath_expression_parser: [:invalid_input],
    xpath_selector: [:invalid, :invalid_input]
  }

  @moduledoc """
  `Meeseeks.Error` provides a generic error struct implementing the
  `Exception` behaviour and containing three keys: `type`, `reason`, and
  `metadata`.

    - `type` is an atom classifying the general context the error exists in, such
  as `:parser`.

    - `reason` is an atom classifying the general problem, such as
  `:invalid_input`.

    - `metadata` is a map containing any additional information useful for
  debugging the error, such as `%{input: "..."}`.

  #{Enum.reduce(@errors, "\n\n### Meeseeks Errors:\n", fn {type, reasons}, acc -> Enum.reduce(reasons, acc, fn reason, acc -> acc <> "\n  - `%Meeseeks.Error{type: #{inspect(type)}, reason: #{inspect(reason)}}`" end) end)}
  """

  @enforce_keys [:type, :reason]
  defexception type: nil, reason: nil, metadata: %{}

  @type type :: atom
  @type reason :: atom
  @type metadata :: %{any => any}

  @type t :: %__MODULE__{
          type: type,
          reason: reason,
          metadata: metadata
        }

  @doc """
  Lists a mapping of error types to reasons for all possible Meeseeks errors.
  """
  @spec list_errors() :: %{type => [reason]}
  def list_errors(), do: @errors

  @doc """
  Creates a new `%Meeseeks.Error{}`.
  """
  @spec new(type, reason, metadata) :: t
  def new(type, reason, metadata \\ %{}) do
    %__MODULE__{type: type, reason: reason, metadata: metadata}
  end

  # Exception callbacks

  @impl true
  def exception(%{type: type, reason: reason} = info) do
    metadata = Map.get(info, :metadata, %{})
    new(type, reason, metadata)
  end

  @impl true
  def message(%__MODULE__{type: type, reason: reason, metadata: metadata}) do
    IO.iodata_to_binary([
      "\n",
      "\n  Type: #{inspect(type)}",
      "\n",
      "\n  Reason: #{inspect(reason)}",
      render_metadata(metadata)
    ])
  end

  # Helpers

  defp render_metadata(%{} = metadata) do
    rendered = for {k, v} <- metadata, do: "\n    #{k}: #{inspect(v)}"

    case rendered do
      [] -> []
      _ -> ["\n\n  Metadata:" | rendered]
    end
  end
end
