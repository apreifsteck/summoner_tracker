defmodule SummonerTracker.Tracker.Trackers.NewMatchesTrackerTest do
  use SummonerTracker.Case, async: true
  alias SummonerTracker.{RiotApi, Summoner}
  alias SummonerTracker.Tracker.Trackers.NewMatchesTracker

  @notification_adapter SummonerTracker.NoficationAdapters.Process
  describe "tracker/3" do
    test "reports when new matches are found" do
      previous_match_ids =
        ["BR1_2922187228", "BR1_2922175461", "BR1_2922157850", "BR1_2922148640", "BR1_2922136701"]

      new_match_ids = ["BR1_new_id" | previous_match_ids]

      Req.Test.stub(RiotApi, fn conn ->
        Req.Test.json(conn, new_match_ids)
      end)

      summoner = Summoner.new!(puuid: "foo", game_name: "austin", tag_line: "cool_guy")

      NewMatchesTracker.track(summoner, "AMERICAS", %{
        previous_match_ids: previous_match_ids,
        notification_adapter: @notification_adapter
      })

      assert_received "Summoner austin#cool_guy completed match BR1_new_id"
    end
  end
end
