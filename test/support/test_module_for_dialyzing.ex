defmodule NimbleOptionsType.TestModuleForDialyzing do
  require NimbleOptionsType

  NimbleOptionsType.generate(:opts,
    name: [required: true, type: :atom],
    an_option: [],
    other_option: []
  )

  @spec hello(opts()) :: :world
  def hello(_opts), do: :world

  def hello() do
    # No warning here:
    hello(name: MyProducer)
    # Dialyzer cannot catch the required option here because NimbleOptions uses keyword lists
    # (it could if these were maps)
    hello(an_option: 1, other_option: 2)

    # Dialyzer catches this one:
    # hello([])
  end
end
