defmodule NimbleOptionsTypeGenTest do
  use ExUnit.Case

  test "generate/2 generates a module attribute" do
    defmodule AModule do
      require NimbleOptionsTypeGen

      NimbleOptionsTypeGen.generate(opts, [])

      assert [
               {:type, {:"::", _, [{:opts, _, nil}, {:list, _, []}]}, _}
             ] = @type
    end
  end
end
