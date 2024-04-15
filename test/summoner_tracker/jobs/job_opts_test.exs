defmodule SummonerTracker.Jobs.JobOptsTest do
  use SummonerTracker.Case, async: true
	alias SummonerTracker.Jobs.JobOpts
  describe "new/1" do
    test "execute_in and execute_every are mutually exclusive" do
      {:ok, _} = JobOpts.new(%{execute_in: 4})
      {:ok, _} = JobOpts.new(%{execute_every: 4})
      {:error, _} = JobOpts.new(%{execute_every: 4, execute_in: 4})
    end

    test "halt_after and halt_at are mutually exclusive" do
      {:ok, _} = JobOpts.new(%{halt_at: 4})
      {:ok, _} = JobOpts.new(%{halt_after: 4})
      {:error, _} = JobOpts.new(%{halt_at: 4, halt_after: 4})
    end
  end
end
