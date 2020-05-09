defmodule NimbleOptionsTypeTest do
  use ExUnit.Case

  test "generate/2 generates a module attribute" do
    defmodule ModuleWithEmptyOptions do
      require NimbleOptionsType

      NimbleOptionsType.generate(opts, [])

      assert [
               {:type, {:"::", _, [{:opts, _, nil}, []]}, _}
             ] = @type
    end
  end

  test "generate/2 works for a simple option" do
    defmodule ModuleWithOneOption do
      require NimbleOptionsType

      NimbleOptionsType.generate(opts, concurrency: [type: :pos_integer])

      assert [
               {:type,
                {:"::", _,
                 [{:opts, _, nil}, {:list, _, [{:concurrency, {:pos_integer, _, []}}]}]}, _}
             ] = @type
    end
  end

  test "generate/2 works for two options" do
    defmodule ModuleWithTwoOptions do
      require NimbleOptionsType

      NimbleOptionsType.generate(opts,
        module: [type: :mod_arg],
        concurrency: [type: :pos_integer]
      )

      assert [
               {:type,
                {:"::", _,
                 [
                   {:opts, _, _},
                   {:list, _,
                    [
                      {:|, _,
                       [
                         concurrency: {:pos_integer, _, []},
                         module: {{:module, _, []}, {:list, _, [{:any, _, []}]}}
                       ]}
                    ]}
                 ]}, _}
             ] = @type
    end
  end

  test "generate/2 marks opts as nonempty_list when opt is required" do
    defmodule ModuleWithRequiredOption do
      require NimbleOptionsType

      NimbleOptionsType.generate(opts, concurrency: [required: true])

      assert [
               {:type,
                {:"::", _,
                 [{:opts, _, nil}, {:nonempty_list, _, [{:concurrency, {:any, _, []}}]}]}, _}
             ] = @type
    end
  end

  test "generate/2 skips deprecated options" do
    defmodule ModuleWithDeprecatedOption do
      require NimbleOptionsType

      NimbleOptionsType.generate(opts, concurrency: [type: :pos_integer, deprecated: true])

      assert [
               {:type, {:"::", _, [{:opts, _, nil}, []]}, _}
             ] = @type
    end
  end
end
