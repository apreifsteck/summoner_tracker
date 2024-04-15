defmodule SummonerTracker do
  @moduledoc """
  Documentation for `SummonerTracker`.
  """
  require Logger
  alias SummonerTracker.{Summoner, RiotApi, Tracker}

  @valid_regions ~w(AMERICAS ASIA EUROPE SEA)
  # Y'all with your beefy api keys can probably ratchet up the concurrency. I hit my rate limits pretty fast.
  @concurrency_opts Application.compile_env!(:summoner_tracker, :api_concurrency_opts)
  @notification_adapter Application.compile_env!(:summoner_tracker, :notification_adapter)
  @task_supervisor SummonerTracker.ApiTaskSupervisor

  @doc """
  Find all summoners this summoner has played in the last 5 matches
  Print to the console any time a summoner completes 
  a match, polling all summoners' matches once a minute for the next hour
  """
  @spec get_summoner_opponent_history(name :: String.t(), region :: String.t()) ::
          {:ok, [String.t()]} | {:error, SummonerTracker.Error.t()}
  def get_summoner_opponent_history(name, region) when region in @valid_regions do
    with {:ok, query} <- Summoner.SearchQuery.from_riot_id(name, region),
         {:ok, summoner} <- RiotApi.get_summoner(query),
         {:ok, match_ids} <- RiotApi.get_last_played_match_ids(summoner, region),
         {:ok, summoners} <- fan_out_match_requests(match_ids, region) do
      attach_trackers_to_summoners(summoners, region)
      {:ok, Enum.map(summoners, &Summoner.riot_id/1)}
    end
  end

  def get_summoner_opponent_history(_name, region) do
    raise ArgumentError, message: "expected region in #{inspect(@valid_regions)}, got: #{region}"
  end

  defp fan_out_match_requests(match_ids, region) do
    match_ids
    |> async_stream(&RiotApi.get_match_by_id(&1, region))
    |> Stream.flat_map(fn {:ok, {:ok, match}} -> match.participant_puuids end)
    # get rid of duplicates
    |> MapSet.new()
    |> Stream.map(&Summoner.SearchQuery.new!(puuid: &1, region: region))
    |> async_stream(fn query -> RiotApi.get_summoner(query) end)
    |> Stream.map(fn
      {:ok, {:ok, summoner}} ->
        summoner
    end)
    |> Enum.to_list()
    |> then(&{:ok, &1})
  end

  defp attach_trackers_to_summoners(summoners, region) do
    summoners
    |> async_stream(&{&1, RiotApi.get_last_played_match_ids(&1, region)})
    |> async_stream_nolink(fn
      {:ok, {summoner, {:ok, match_ids}}} ->
        Tracker.attach_tracker_for(summoner, region, %{
          notification_adapter: @notification_adapter,
          previous_match_ids: match_ids
        })

      other ->
        Logger.error("could not attach tracker for a summoner. Result: #{inspect(other)}")
        other
    end)
    |> Stream.run()
  end

  defp async_stream(enum, func) do
    Task.Supervisor.async_stream(
      @task_supervisor,
      enum,
      func,
      @concurrency_opts
    )
  end

  defp async_stream_nolink(enum, func) do
    Task.Supervisor.async_stream(
      @task_supervisor,
      enum,
      func,
      @concurrency_opts
    )
  end
end
