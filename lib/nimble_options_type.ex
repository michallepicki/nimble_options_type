defmodule NimbleOptionsType do
  @moduledoc """
  Documentation for `NimbleOptionsType`.
  """

  @doc """
  Generates a `@type` spec for `type_name` according to given `NimbleOptions` `schema`.
  """
  defmacro generate(type_name, schema) do
    typespec = get_types(schema, nil, false)

    [
      {:@, [], [{:type, [], [{:"::", [], [{type_name, [], []}, typespec]}]}]},
      {:@, [], [{type_name, [], [schema]}]}
    ]
  end

  defp get_types(schema, acc, nonempty?)

  defp get_types([], nil, _nonempty?) do
    # why would anyone want to have always empty options? dunno
    []
  end

  defp get_types([], acc, _nonempty?) do
    acc
  end

  defp get_types([{key, definition} | rest], acc, nonempty?) do
    get_types(
      rest,
      add_type(
        key(key),
        type(definition[:type] || :any, definition[:keys]),
        definition[:required] || nonempty?,
        definition[:deprecated] || false,
        acc
      ),
      nonempty?
    )
  end

  # don't add deprecated options
  defp add_type(_key, _type, _required?, deprecated?, acc) when deprecated?, do: acc

  # this is our first option
  defp add_type(key, type, required?, _deprecated?, nil) do
    list_type =
      case required? do
        true -> :nonempty_list
        false -> :list
      end

    {list_type, [], [{key, type}]}
  end

  # we already have something
  defp add_type(key, type, required?, _deprecated?, {list_type, [], [existing_options_type]}) do
    list_type =
      case list_type == :nonempty_list || required? do
        true -> :nonempty_list
        false -> :list
      end

    {list_type, [], type_or_type({key, type}, existing_options_type)}
  end

  defp type_or_type(a, b) do
    [{:|, [], [a, b]}]
  end

  defp key(:*), do: quote(do: atom())
  defp key(atom), do: atom

  defp type(type, _)
       when type in [
              :any,
              :atom,
              :boolean,
              :non_neg_integer,
              :pos_integer,
              :timeout,
              :mfa
            ],
       do: {type, [], []}

  defp type(type, keys) when type in [:keyword_list, :non_empty_keyword_list] do
    nonempty? =
      case type do
        :keyword_list -> false
        :non_empty_keyword_list -> true
      end

    get_types(keys, nil, nonempty?)
  end

  defp type(:mod_arg, _), do: quote(do: {module(), list(any())})
  defp type(:string, _), do: quote(do: String.t())

  defp type({:fun, arity}, _),
    do: [{:->, [], [Enum.map(1..arity, fn _ -> {:any, [], []} end), {:any, [], []}]}]

  defp type({:custom, _, _, _}, _), do: quote(do: any())
  # TODO this is pobably wrong
  defp type({:one_of, choices}, _), do: Enum.reduce(choices, &type_or_type/2)
end
