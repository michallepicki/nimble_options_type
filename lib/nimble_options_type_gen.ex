defmodule NimbleOptionsTypeGen do
  @moduledoc """
  Documentation for `NimbleOptionsTypeGen`.
  """

  @doc """
  Generates a `@type` spec for `type_name` according to given `NimbleOptions` `schema`.
  """
  defmacro generate(type_name, _schema) do
    list = {:list, [], []}
    list = Macro.expand(list, __CALLER__)
    quote do
      @type unquote(type_name) :: unquote(list)
    end
  end
end
