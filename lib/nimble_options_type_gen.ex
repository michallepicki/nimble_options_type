defmodule NimbleOptionsTypeGen do
  @moduledoc """
  Documentation for `NimbleOptionsTypeGen`.
  """

  @doc """
  Generates a `@type` spec for `type_name` according to given `NimbleOptions` `schema`.
  """
  defmacro generate(type_name, schema) do
    # TODO there's probably some unnecessary macro sillyness here
    typespec = get_types(schema, nil)
    typespec = Macro.expand(typespec, __CALLER__)
    quote do
      @type unquote(type_name) :: unquote(typespec)
    end
  end

  defp get_types([], nil) do
    # why would anyone want to pass empty schema? dunno
    []
  end
  defp get_types([], acc) do
    acc
  end
  defp get_types([{key, definition} | rest], acc) do
    get_types(rest, add_type(key, type(definition[:type] || :any), definition[:required] || false, acc))
  end
  # this is our first option
  defp add_type(key, type, required?, nil) do
    list_type = case required? do
      true -> :nonempty_list
      false -> :list
    end
    {list_type, [], [{key, type}]}
  end

  # we already have something
  defp add_type(key, type, required?, {list_type, [], [existing_options_type]}) do
    list_type = case (list_type == :nonempty_list) || required? do
      true -> :nonempty_list
      false -> :list
    end
    {list_type, [], type_or_type({key, type}, existing_options_type)}
  end

  defp type_or_type(a, b) do
    [{:|, [], [a, b]}]
  end

  defp type(type) when type in [:any, :keyword_list, :non_empty_keyword_list, :atom, :boolean, :non_neg_integer, :pos_integer, :timeout, :mfa], do: {type, [], []}
  defp type(:mod_arg), do: quote do: {module(), list(any())}
  defp type(:string), do: quote do: String.t()
  defp type({:fun, arity}), do: [{:->, [], [Enum.map(1..arity, fn _ -> {:any, [], []} end), {:any, [], []}]}]
  defp type({:custom, _, _, _}), do: quote do: any()
  # TODO this is pobably wrong
  defp type({:one_of, choices}), do: Enum.reduce(choices, &type_or_type/2)
end
