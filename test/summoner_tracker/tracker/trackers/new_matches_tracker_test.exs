defmodule SummonerTracker.Tracker.Trackers.NewMatchesTrackerTest do
  use SummonerTracker.Case, async: true
  alias SummonerTracker.{RiotApi, Summoner}
  alias SummonerTracker.Tracker.Trackers.NewMatchesTracker

  @notification_adapter SummonerTracker.NotificationAdapters.Process
  setup do
    summoner = Summoner.new!(puuid: "foo", game_name: "austin", tag_line: "cool_guy")
    {:ok, summoner: summoner}
  end

  describe "tracker/3" do
    test "reports when new matches are found", context do
      previous_match_ids =
        ["BR1_2922187228", "BR1_2922175461", "BR1_2922157850", "BR1_2922148640", "BR1_2922136701"]

      new_match_ids = ["BR1_new_id" | previous_match_ids]

      Req.Test.stub(RiotApi, fn conn ->
        Req.Test.json(conn, new_match_ids)
      end)

      assert %{previous_match_ids: ids} =
               NewMatchesTracker.track(context.summoner, "AMERICAS", %{
                 previous_match_ids: previous_match_ids,
                 notification_adapter: @notification_adapter
               })

      assert ids == MapSet.new(new_match_ids)

      assert_received "Summoner austin#cool_guy completed match BR1_new_id"
    end

    test "does not report when there are no new matches", context do
      previous_match_ids =
        ["BR1_2922187228", "BR1_2922175461", "BR1_2922157850", "BR1_2922148640", "BR1_2922136701"]

      Req.Test.stub(RiotApi, fn conn ->
        Req.Test.json(conn, previous_match_ids)
      end)

      assert %{previous_match_ids: ids} =
               NewMatchesTracker.track(context.summoner, "AMERICAS", %{
                 previous_match_ids: previous_match_ids,
                 notification_adapter: @notification_adapter
               })

      assert ids == MapSet.new(previous_match_ids)

      refute_received _
    end
  end
end
