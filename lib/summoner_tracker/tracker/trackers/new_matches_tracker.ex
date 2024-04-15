defmodule SummonerTracker.Tracker.Trackers.NewMatchesTracker do
  @moduledoc """
  Tracks a summoners matches. If new matches are found to have been played after old ones,
  sends a notification that the summoner has completed a match.

  arguments are: 
  `notification_adapter`: An implementor of `SummonerTracker.NotifiticationAdapter` to determine how to send the message.
  `previous_match_ids`: a list of match ids that the summoner has participated in in the recent past. 
  Match IDs recently fetched that are different from this list are considered to be new matches.
  """
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
