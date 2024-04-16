defmodule SummonerTrackerTest do
  use SummonerTracker.Case, async: true
  alias SummonerTracker.Error
  alias SummonerTracker.RiotApi
  alias SummonerTracker.RiotApi.MockApi
  doctest SummonerTracker

  setup do
    %{ name: "austin#BR_1", region: "AMERICAS"}
  end

  test "returns all the summoners a summoner played in the last X matches", %{name: name, region: region} do
    assert {:ok, summoners} = SummonerTracker.get_summoner_opponent_history(name, region)
    assert length(summoners) > 0
    assert summoners |> hd() |> String.contains?("#")
  end

  test "returns an empty list if the summoner has not played anyone ever", %{name: name, region: region} do
    Req.Test.stub(RiotApi, fn conn ->
      if String.contains?(conn.request_path, "matches/by-puuid") do
        Req.Test.json(conn, [])
      else
        MockApi.default_stub(conn)
      end
    end)

    assert {:ok, []} = SummonerTracker.get_summoner_opponent_history(name, region)
  end

  test "returns an error if the summoner can't be found", %{name: name, region: region} do
    Req.Test.stub(RiotApi, fn conn ->
      if String.contains?(conn.request_path, "accounts") do
        Plug.Conn.resp(conn,
          404,
          Jason.encode!(%{
            status: %{
              status_code: 404,
              message: "Data not found - No results found for player with riot id bar#foo"
            }
          })
        )
      else
        MockApi.default_stub(conn)
      end
    end)

    assert {:error, %Error{type: :summoner_not_found}} =
             SummonerTracker.get_summoner_opponent_history(name, region)
  end

  test "handles bad input" do
    name = "austin#1234"

    assert_raise(ArgumentError, fn ->
      SummonerTracker.get_summoner_opponent_history(name, "foo")
    end)

    assert {:error, %Error{type: :validation_error}} =
             SummonerTracker.get_summoner_opponent_history("boo", "SEA")
  end
end
