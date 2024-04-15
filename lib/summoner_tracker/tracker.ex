defmodule SummonerTracker.Tracker do
  @moduledoc """
  A way of tracking summoner statistics on regular intervals
  """
  alias SummonerTracker.{Summoner, Jobs}

  @callback track(summoner :: Summoner.t(), region :: String.t(), args :: map()) ::
              new_args :: map()

  @type milliseconds :: integer()
  @doc """
  For a given summoner, runs a periodic job to track their records in some way.
  Trackers are modules that implement the `SummonerTracker.Tracker` behaviour.
  """
  @spec attach_tracker_for(
          summoner :: Summoner.t(),
          region :: String.t(),
          initial_state :: any(),
          tracker :: module(),
          duration :: milliseconds(),
          interval :: milliseconds()
        ) ::
          :ok
  def attach_tracker_for(
        %Summoner{} = summoner,
        region,
        initial_state,
        tracker \\ __MODULE__.Trackers.NewMatchesTracker,
        duration \\ :timer.hours(1),
        interval \\ :timer.minutes(1)
      ) do
    job_opts =
      Jobs.JobOpts.new!(
        execute_every: interval,
        halt_after: duration,
        jitter: -4_000..4_000,
        state: initial_state
      )

    Jobs.add_job(
      fn
        state ->
          tracker.track(summoner, region, state)
      end,
      job_opts
    )

    :ok
  end
end
