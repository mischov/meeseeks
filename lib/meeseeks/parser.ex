defmodule Meeseeks.Parser do
  @moduledoc false

  alias Meeseeks.{Document, Error, TupleTree}
  alias Meeseeks.Document.{Comment, Data, Doctype, Element, ProcessingInstruction, Text}

  @type source :: String.t() | TupleTree.t()
  @type type :: :html | :xml | :tuple_tree

  # Parse

  @spec parse(source) :: Document.t() | {:error, Error.t()}

  def parse(string) when is_binary(string) do
    case MeeseeksHtml5ever.parse_html(string) do
      {:ok, document} ->
        document

      {:error, description} ->
        {:error,
         Error.new(:parser, :invalid_input, %{
           description: description,
           input: string
         })}
    end
  end

  def parse(tuple_tree) do
    IO.warn(
      "parse/1 with a tuple tree is deprecated. " <>
        "Please use parse/2 with the :tuple_tree type instead."
    )

    parse(tuple_tree, :tuple_tree)
  end

  @spec parse(source, type) :: Document.t() | {:error, Error.t()}

  def parse(string, :html) when is_binary(string) do
    case MeeseeksHtml5ever.parse_html(string) do
      {:ok, document} -> document
      {:error, error} -> {:error, error}
    end
  end

  def parse(string, :xml) when is_binary(string) do
    case MeeseeksHtml5ever.parse_xml(string) do
      {:ok, document} -> document
      {:error, error} -> {:error, error}
    end
  end

  def parse(tuple_tree, :tuple_tree) when is_list(tuple_tree) or is_tuple(tuple_tree) do
    parse_tuple_tree(tuple_tree)
  end

  # parse_tuple_tree

  @spec parse_tuple_tree(TupleTree.t()) :: Document.t() | {:error, Error.t()}

  defp parse_tuple_tree(tuple_tree) when is_list(tuple_tree) do
    add_root_nodes(%Document{}, tuple_tree)
  end

  defp parse_tuple_tree(tuple_tree) when is_tuple(tuple_tree) do
    add_root_node(%Document{}, tuple_tree)
  end

  # add_root_nodes

  defp add_root_nodes(document, roots) do
    Enum.reduce_while(roots, document, fn root, doc ->
      case add_root_node(doc, root) do
        %Document{} = doc -> {:cont, doc}
        {:error, _} = err -> {:halt, err}
      end
    end)
  end

  # add_root_node

  # Comment

  defp add_root_node(document, {:comment, comment} = input) do
    with true <- is_binary(comment) do
      id = next_id(document.id_counter)
      node = %Comment{id: id, content: comment}
      insert_root_node(document, id, node)
    else
      _ -> {:error, invalid_node(input)}
    end
  end

  # Doctype

  defp add_root_node(document, {:doctype, name, public, system} = input) do
    with true <- is_binary(name),
         true <- is_binary(public),
         true <- is_binary(system) do
      id = next_id(document.id_counter)
      node = %Doctype{id: id, name: name, public: public, system: system}
      insert_root_node(document, id, node)
    else
      _ -> {:error, invalid_node(input)}
    end
  end

  # Element

  defp add_root_node(document, {tag, attributes, children} = input) when is_binary(tag) do
    with true <- valid_attributes?(attributes),
         true <- is_list(children) do
      id = next_id(document.id_counter)
      [ns, tg] = split_namespace_from_tag(tag)
      node = %Element{id: id, namespace: ns, tag: tg, attributes: attributes}

      insert_root_node(document, id, node)
      |> add_child_nodes(id, children)
    else
      _ -> {:error, invalid_node(input)}
    end
  end

  # ProcessingInstruction

  # :mochiweb_html parses <?php ...?> to {:pi, "php ..."}
  defp add_root_node(document, {:pi, <<"php" <> data>>}) do
    id = next_id(document.id_counter)
    data = String.trim(data)
    node = %ProcessingInstruction{id: id, target: "php", data: data}
    insert_root_node(document, id, node)
  end

  # `:mochiweb_html` parses `<?target data ?>` into `{:pi, "target", [{"data", "data"}]}`
  defp add_root_node(document, {:pi, target, attributes} = input) when is_list(attributes) do
    with true <- is_binary(target) do
      id = next_id(document.id_counter)
      data = join_pi(attributes)
      node = %ProcessingInstruction{id: id, target: target, data: data}
      insert_root_node(document, id, node)
    else
      _ -> {:error, invalid_node(input)}
    end
  end

  defp add_root_node(document, {:pi, target, data} = input) do
    with true <- is_binary(target),
         true <- is_binary(data) do
      id = next_id(document.id_counter)
      node = %ProcessingInstruction{id: id, target: target, data: data}
      insert_root_node(document, id, node)
    else
      _ -> {:error, invalid_node(input)}
    end
  end

  # else

  defp add_root_node(_document, other) do
    {:error, invalid_node(other)}
  end

  # add_child_nodes

  defp add_child_nodes(document, parent_id, children) do
    Enum.reduce_while(children, document, fn child, doc ->
      case add_child_node(doc, parent_id, child) do
        %Document{} = doc -> {:cont, doc}
        {:error, _} = err -> {:halt, err}
      end
    end)
  end

  # add_child_node

  # Comment

  defp add_child_node(document, parent, {:comment, comment} = input) do
    with true <- is_binary(comment) do
      id = next_id(document.id_counter)
      node = %Comment{parent: parent, id: id, content: comment}
      insert_node(document, id, node)
    else
      _ -> {:error, invalid_node(input)}
    end
  end

  # Data | Text

  defp add_child_node(document, parent, text) when is_binary(text) do
    id = next_id(document.id_counter)
    parent_node = Document.get_node(document, parent)

    if parent_node.tag == "script" or parent_node.tag == "style" do
      node = %Data{parent: parent, id: id, content: text}
      insert_node(document, id, node)
    else
      node = %Text{parent: parent, id: id, content: text}
      insert_node(document, id, node)
    end
  end

  # Element

  defp add_child_node(document, parent, {tag, attributes, children} = input)
       when is_binary(tag) do
    with true <- valid_attributes?(attributes),
         true <- is_list(children) do
      id = next_id(document.id_counter)
      [ns, tg] = split_namespace_from_tag(tag)
      node = %Element{parent: parent, id: id, namespace: ns, tag: tg, attributes: attributes}

      insert_node(document, id, node)
      |> add_child_nodes(id, children)
    else
      _ -> {:error, invalid_node(input)}
    end
  end

  # ProcessingInstruction

  # :mochiweb_html parses <?php ... ?> to {:pi, "php ..."}
  defp add_child_node(document, parent, {:pi, <<"php" <> data>>}) do
    id = next_id(document.id_counter)
    data = String.trim(data)
    node = %ProcessingInstruction{parent: parent, id: id, target: "php", data: data}
    insert_node(document, id, node)
  end

  # `:mochiweb_html` parses `<?target data ?>` into `{:pi, "target", [{"data", "data"}]}`
  defp add_child_node(document, parent, {:pi, target, attributes} = input)
       when is_list(attributes) do
    with true <- is_binary(target) do
      id = next_id(document.id_counter)
      data = join_pi(attributes)
      node = %ProcessingInstruction{parent: parent, id: id, target: target, data: data}
      insert_node(document, id, node)
    else
      _ -> {:error, invalid_node(input)}
    end
  end

  defp add_child_node(document, parent, {:pi, target, data} = input) do
    with true <- is_binary(target),
         true <- is_binary(data) do
      id = next_id(document.id_counter)
      node = %ProcessingInstruction{parent: parent, id: id, target: target, data: data}
      insert_node(document, id, node)
    else
      _ -> {:error, invalid_node(input)}
    end
  end

  # else

  defp add_child_node(_document, _parent, other) do
    {:error, invalid_node(other)}
  end

  # helpers

  defp next_id(nil), do: 1
  defp next_id(n), do: n + 1

  # Attempting to handle `:mochiweb_html`'s absurdly bad parsing
  # of processing instruction data into `[{attribute, value}]`
  defp join_pi([]) do
    ""
  end

  defp join_pi(attributes) do
    attributes
    |> Enum.reduce("", &join_pi(&1, &2))
    |> String.trim()
  end

  defp join_pi({a, v}, acc) when a == v do
    "#{acc} #{a}"
  end

  defp join_pi({a, v}, acc) do
    "#{acc} #{a}=\"#{v}\""
  end

  defp split_namespace_from_tag(maybe_namespaced_tag) do
    case :binary.split(maybe_namespaced_tag, ":", []) do
      [tg] -> ["", tg]
      [ns, tg] -> [ns, tg]
    end
  end

  defp insert_root_node(%{nodes: nodes} = document, id, node) do
    nodes = Map.put(nodes, id, node)

    %{
      document
      | id_counter: id,
        roots: document.roots ++ [id],
        nodes: nodes
    }
  end

  defp insert_node(%{nodes: nodes} = document, id, %{parent: parent} = node) do
    %{children: children} = parent_node = Map.fetch!(nodes, parent)

    nodes =
      nodes
      |> Map.put(id, node)
      # List append is less expensive than rewalking all of the nodes at
      # the end and reversing children.
      |> Map.put(parent, %{parent_node | children: children ++ [id]})

    %{document | id_counter: id, nodes: nodes}
  end

  defp valid_attributes?(attributes) when is_list(attributes) do
    Enum.all?(attributes, fn {k, v} -> is_binary(k) and is_binary(v) end)
  end

  defp valid_attributes?(_), do: false

  defp invalid_node(input) do
    Error.new(:parser, :invalid_input, %{
      description: "invalid tuple tree node",
      input: input
    })
  end
end
