defmodule SummonerTracker.Tracker.Trackers.NewMatchesTracker do
  require Logger
  alias SummonerTracker.Summoner

  @behaviour SummonerTracker.Tracker

  @impl true
  def track(summoner, region, %{
        notification_adapter: notification_adapter,
        previous_match_ids: previous_match_ids
      }) do
    previous_match_ids = MapSet.new(previous_match_ids)

    # The assumption is that any new ids are completed games
    match_ids =
      case SummonerTracker.RiotApi.get_last_played_match_ids(summoner, region) do
        {:ok, new_match_ids} ->
          new_match_ids =
            new_match_ids
            |> MapSet.new()

          new_match_ids
          |> MapSet.difference(previous_match_ids)
          |> Enum.each(
            &notification_adapter.send(
              "Summoner #{Summoner.riot_id(summoner)} completed match #{&1}"
            )
          )

          new_match_ids

        {:error, error} ->
          Logger.error(
            "Could not retreive match ids for summoner #{inspect(summoner)}, got error: #{inspect(error)}"
          )

          previous_match_ids
      end

    %{notification_adapter: notification_adapter, previous_match_ids: match_ids}
  end
end
