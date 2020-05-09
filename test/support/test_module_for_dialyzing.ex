defmodule NimbleOptionsTypeGen.TestModuleForDialyzing do
  require NimbleOptionsTypeGen

  # TODO: move each error example into separate funcitons and run dialyzer in tests to see if errors get generated

  NimbleOptionsTypeGen.generate(opts, [])

  @spec hello(opts()) :: :world
  def hello(_opts), do: :world

  def hello() do
    # Dialyzer warning shows up for calls below:

    # hello(nil)

    # The function call will not succeed.
    # NimbleOptionsTypeGen.TestModuleForDialyzing.hello(nil)
    # breaks the contract
    # (opts()) :: :world

    # hello([option: :invalid])

    # The function call will not succeed.
    # NimbleOptionsTypeGen.TestModuleForDialyzing.hello([{:option, :invalid}])
    # breaks the contract
    # (opts()) :: :world

    # No warning here:

    hello([])
  end

  NimbleOptionsTypeGen.generate(simple_opts, concurrency: [type: :pos_integer])

  @spec hello2(simple_opts()) :: :world
  def hello2(_simple_opts), do: :world

  def hello2() do
    # Dialyzer warning shows up for calls below:

    # hello2([asdf: :bad_option])

    # The function call will not succeed.
    # NimbleOptionsTypeGen.TestModuleForDialyzing.hello2([{:asdf, :bad_option}])
    # breaks the contract
    # (simple_opts()) :: :world

    # hello2([concurrency: :bad_value])

    # The function call will not succeed.
    # NimbleOptionsTypeGen.TestModuleForDialyzing.hello2([{:concurrency, :bad_value}])
    # breaks the contract
    # (simple_opts()) :: :world

    # hello2([concurrency: 0])

    # The function call will not succeed.
    # NimbleOptionsTypeGen.TestModuleForDialyzing.hello2([{:concurrency, 0}])
    # breaks the contract
    # (simple_opts()) :: :world

    # No warning here:

    hello2(concurrency: 2)
  end

  NimbleOptionsTypeGen.generate(simple_required_opts,
    concurrency: [type: :pos_integer, required: true]
  )

  @spec hello3(simple_required_opts()) :: :world
  def hello3(_simple_required_opts), do: :world

  def hello3() do
    # Dialyzer warning shows up for calls below:
    # hello3([])

    # The function call will not succeed.
    # NimbleOptionsTypeGen.TestModuleForDialyzing.hello3([])
    # breaks the contract
    # (simple_required_opts()) :: :world

    # hello3([wrong_opt: 2])

    # The function call will not succeed.
    # NimbleOptionsTypeGen.TestModuleForDialyzing.hello3([{:wrong_opt, 2}])
    # breaks the contract
    # (simple_required_opts()) :: :world

    # No warnings here:
    hello3(concurrency: 3)
  end
end
