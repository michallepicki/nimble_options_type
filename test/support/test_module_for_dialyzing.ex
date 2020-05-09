defmodule NimbleOptionsTypeGen.TestModuleForDialyzing do
  require NimbleOptionsTypeGen

  NimbleOptionsTypeGen.generate(opts, [])

  @spec hello(opts()) :: :world
  def hello(_opts), do: :world

  def hello() do
    # Dialyzer warning below:
    # The function call will not succeed.
    #
    # NimbleOptionsTypeGen.TestModuleForDialyzing.hello(nil)
    #
    # breaks the contract
    # (opts()) :: :world
    hello(nil)
  end
end
