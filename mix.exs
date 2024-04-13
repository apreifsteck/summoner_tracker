defmodule SummonerTracker.MixProject do
  use Mix.Project

  def project do
    [
      app: :summoner_tracker,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {SummonerTracker.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:decorator, "~> 1.4"}, 
      {:nebulex, "~> 2.6"},
      {:plug, "~> 1.0"},
      {:req, "~> 0.4.0"},
      {:strukt, "~> 0.3"}
    ]
  end
end
