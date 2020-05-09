defmodule NimbleOptionsTypeGen.MixProject do
  use Mix.Project

  def project do
    [
      app: :nimble_options_type_gen,
      version: "0.2.0",
      elixir: "~> 1.0",
      start_permanent: Mix.env() == :prod,
      deps: [],
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    []
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
