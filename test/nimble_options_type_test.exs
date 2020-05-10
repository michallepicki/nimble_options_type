defmodule NimbleOptionsTypeTest do
  use ExUnit.Case

  test "generate/2 generates a module attribute" do
    defmodule ModuleWithEmptyOptions do
      require NimbleOptionsType

      NimbleOptionsType.generate(:opts, [])
      # results in:
      # @type opts() :: []

      assert [
               {:type, {:"::", _, [{:opts, _, []}, []]}, _}
             ] = @type
    end
  end

  test "generate/2 works for a simple option" do
    defmodule ModuleWithOneOption do
      require NimbleOptionsType

      NimbleOptionsType.generate(:opts, concurrency: [type: :pos_integer])
      # results in:
      # @type opts() :: list({:concurrency, pos_integer()})

      assert [
               {:type,
                {:"::", _, [{:opts, _, []}, {:list, _, [{:concurrency, {:pos_integer, _, []}}]}]},
                _}
             ] = @type
    end
  end

  test "generate/2 works for two options" do
    defmodule ModuleWithTwoOptions do
      require NimbleOptionsType

      NimbleOptionsType.generate(:opts,
        module: [type: :mod_arg],
        concurrency: [type: :pos_integer]
      )

      # results in:
      # @type opts() :: list({:concurrency, pos_integer()} | {:module, {module(), list(any())})

      assert [
               {:type,
                {:"::", _,
                 [
                   {:opts, _, []},
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

      NimbleOptionsType.generate(:opts, concurrency: [required: true])
      # results in:
      # @type opts() :: nonempty_list({:concurrency, any()})

      assert [
               {:type,
                {:"::", _,
                 [{:opts, _, []}, {:nonempty_list, _, [{:concurrency, {:any, _, []}}]}]}, _}
             ] = @type
    end
  end

  test "generate/2 skips deprecated options" do
    defmodule ModuleWithDeprecatedOption do
      require NimbleOptionsType

      NimbleOptionsType.generate(:opts, concurrency: [type: :pos_integer, deprecated: true])
      # results in:
      # @type opts() :: []

      assert [
               {:type, {:"::", _, [{:opts, _, []}, []]}, _}
             ] = @type
    end
  end

  test "generate/2 works for nested keyword lists options" do
    defmodule ModuleWithNestedKeywordListsOptions do
      require NimbleOptionsType

      NimbleOptionsType.generate(:opts,
        producer: [
          type: :non_empty_keyword_list,
          keys: [
            module: [type: :mod_arg],
            rate_limiting: [
              type: :non_empty_keyword_list,
              keys: [
                allowed_messages: [type: :pos_integer],
                interval: [required: true, type: :pos_integer]
              ]
            ]
          ]
        ]
      )

      # results in:
      # @type opts() ::
      #         list(
      #           {:producer,
      #            nonempty_list(
      #              {:rate_limiting,
      #               nonempty_list({:interval, pos_integer()} | {:allowed_messages, pos_integer()})}
      #              | {:module, {module(), list(any())}}
      #            )}
      #         )

      assert [
               {:type,
                {:"::", _,
                 [
                   {:opts, _, []},
                   {:list, _,
                    [
                      producer:
                        {:nonempty_list, _,
                         [
                           {:|, _,
                            [
                              rate_limiting:
                                {:nonempty_list, _,
                                 [
                                   {:|, _,
                                    [
                                      interval: {:pos_integer, _, []},
                                      allowed_messages: {:pos_integer, _, []}
                                    ]}
                                 ]},
                              module: {{:module, _, []}, {:list, _, [{:any, _, []}]}}
                            ]}
                         ]}
                    ]}
                 ]}, _}
             ] = @type
    end
  end
end
