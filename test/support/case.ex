defmodule SummonerTracker.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      setup do
        SummonerTracker.RiotApi.MockApi.setup_default_stub()
        :ok
      end
    end
  end
end
