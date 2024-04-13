defmodule SummonerTracker do
  @moduledoc """
  Documentation for `SummonerTracker`.
  """
  alias SummonerTracker.{Summoner, RiotApi}

  # @doc """

  # Find all summoners this summoner has played in the last 5 matches
  # Print to the console any time any(?) summoner wins a match, polling all summoners once a minute for the next hour

  # # Considerations
  # - What if we want to fetch a summoner by RiotID or other means in the future?
  # - What if we want to change the number of matches that we look back by?
  # - What if we want to change how often we poll or how long to poll for?
  # - What if we want to change how reports of summoner wins are created?
  # """
  def get_summoner_opponent_history(name, region) do
    with {:ok, query} <- Summoner.SearchQuery.from_name(name, region),
         {:ok, summoner} <- RiotApi.get_summoner(query),
         {:ok, match_ids} <- RiotApi.get_last_played_match_ids(summoner, region),
         {:ok, summoners} <- fan_out_match_requests(match_ids, region) do
      Enum.map(summoners, &Summoner.riot_id/1)
    end
  end

  defp fan_out_match_requests(match_ids, region) do
    match_ids
    |> Task.async_stream(&RiotApi.get_match_by_id(&1, region))
    |> Stream.flat_map(fn {:ok, {:ok, match}} -> match.participant_puuids end)
    |> MapSet.new() # get rid of duplicates
    |> Stream.map(&Summoner.SearchQuery.new!(puuid: &1, region: region))
    # avoid slaughtering your rate limit
    |> Task.async_stream(&RiotApi.get_summoner/1, max_concurrency: 2)
    |> Stream.map(fn {:ok, {:ok, summoner}} -> summoner end)
    |> Enum.to_list()
    |> then(&{:ok, &1})
  end
end
