defmodule NimbleOptionsTypeTest do
  use ExUnit.Case

  test "generate/2 generates the type spec and a module attribute with the schema" do
    defmodule ModuleWithEmptyOptions do
      require NimbleOptionsType

      NimbleOptionsType.generate(:opts, [])
      # results in:
      # @type opts() :: []
      # @opts []

      assert [
               {:type, {:"::", _, [{:opts, _, []}, []]}, _}
             ] = @type

      assert [] == @opts
    end
  end

  test "generate/2 works for a simple option" do
    defmodule ModuleWithOneOption do
      require NimbleOptionsType

      NimbleOptionsType.generate(:opts, concurrency: [type: :pos_integer])
      # results in:
      # @type opts() :: list({:concurrency, pos_integer()})
      # @opts [concurrency: [type: :pos_integer]]

      assert [
               {:type,
                {:"::", _, [{:opts, _, []}, {:list, _, [{:concurrency, {:pos_integer, _, []}}]}]},
                _}
             ] = @type

      assert [concurrency: [type: :pos_integer]] == @opts
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
      # @opts [module: [type: :mod_arg], concurrency: [type: :pos_integer]]

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

      assert [module: [type: :mod_arg], concurrency: [type: :pos_integer]] == @opts
    end
  end

  test "generate/2 marks opts as nonempty_list when opt is required" do
    defmodule ModuleWithRequiredOption do
      require NimbleOptionsType

      NimbleOptionsType.generate(:opts, concurrency: [required: true])
      # results in:
      # @type opts() :: nonempty_list({:concurrency, any()})
      # @opts [concurrency: [required: true]]

      assert [
               {:type,
                {:"::", _,
                 [{:opts, _, []}, {:nonempty_list, _, [{:concurrency, {:any, _, []}}]}]}, _}
             ] = @type

      assert [concurrency: [required: true]] == @opts
    end
  end

  test "generate/2 skips deprecated options" do
    defmodule ModuleWithDeprecatedOption do
      require NimbleOptionsType

      NimbleOptionsType.generate(:opts, concurrency: [type: :pos_integer, deprecated: true])
      # results in:
      # @type opts() :: []
      # @opts [concurrency: [type: :pos_integer, deprecated: true]]

      assert [
               {:type, {:"::", _, [{:opts, _, []}, []]}, _}
             ] = @type

      assert [concurrency: [type: :pos_integer, deprecated: true]] == @opts
    end
  end

  test "generate/2 works for :*" do
    defmodule ModuleWithWildcardOptions do
      require NimbleOptionsType

      NimbleOptionsType.generate(:opts, *: [])
      # results in:
      # @type opts() :: list({atom(), any()})
      # @opts [*: []]
      assert [
               {:type,
                {:"::", _, [{:opts, _, []}, {:list, _, [{{:atom, _, []}, {:any, _, []}}]}]}, _}
             ] = @type

      assert [*: []] == @opts
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
      # @opts [
      #   producer: [
      #     type: :non_empty_keyword_list,
      #     keys: [
      #       module: [type: :mod_arg],
      #       rate_limiting: [
      #         type: :non_empty_keyword_list,
      #         keys: [
      #           allowed_messages: [type: :pos_integer],
      #           interval: [required: true, type: :pos_integer]
      #         ]
      #       ]
      #     ]
      #   ]
      # ]

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

      assert [
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
             ] == @opts
    end
  end

  # TODO how to deal with recursive types?
end
