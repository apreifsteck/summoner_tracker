defmodule SummonerTrackerTest do
  use SummonerTracker.Case, async: true
  alias SummonerTracker.Error
  doctest SummonerTracker

  @expected_summoners [
    "09NFMe2DNLc_f3jtoKPKUQNEEg9KUdpi3Fa2kfXLOUej2U3YdBiSYhLw98SU1rSefLmuA33yllVfvg",
    "ZHrrNgPGcmiqXCOBlGojPNUk3xXLz55CgfWdFkZoFlSoV20M31bk3DnD_nlOwT3T5n1Ujb9XNFx7EQ",
    "Vo6meuUc-qp3YavORSEa-6TpzaMiqI4tIbBwt77rHR3UJ0d6ur_DTMt5mPp2Sw5km3_qciJV4JLN8A",
    "YTnpngYri6LpmcfSHBDf6l2vEIzy3ymGN_YYwy1mmWV6pTgMsZttpVYC4HdG3aOicb8naHaTnoaTFQ",
    "k_vDs0ooPQEV6mApPnacnM2JFVLqBdJbzOpmPW15L7AYxULvBcFOMIxAHI9uoH4eQrtcdj55EOCbmA",
    "JG4GTcFvs3FgP2DFNttz-k18RPQVzqzEpHqgThzz4FgQMgkaPCOSsDOILpwLKBOAjh-6AL7BpnpiiQ",
    "XHjmN3SmiOK6CGisQIQl953a7m089mLcHvZXGe-2acaz-n8wdqd-jslpTf4MUgtCqFEXZ1bIV832IA",
    "OF6OZ4lFqrt7B-yyXimuiaCFxkD21FauSnl8r6NSM4nOxIW1x8ZlYNEQeGIessOKLxtvLT61EMCTWw",
    "kgXbvP8ILKoPWtl7KAfZZcLB97u1KXL5YrAobWkLfITbV6lZbVWGuL6fn-uXEPOL8rxpk2rnG6eTMw",
    "rXVwb10KBzO2r19X3xJ6wc6Gr3EO5hv80WDvXXdRP5NvkrbPc7phh8se0IOdn_tjtjEiidYcd3hFXw"
  ]
  |> then(&%{puuid: &1})
  # |>

  test "returns all the summoners a summoner played in the last X matches" do
    name = "austin#1234"
    region = "AMERICAS"
    assert {:ok, []} = SummonerTracker.get_summoner_opponent_history(name, region)
  end

  # test "returns an empty list if the summoner has not played anyone ever" do
  #   assert {:ok, []} = SummonerTracker.get_summoner_opponent_history(name, region)
  # end

  # test "returns an error if the summoner can't be found" do
  #   assert {:error, %Error{type: :summoner_not_found}} =
  #            SummonerTracker.get_summoner_opponent_history(name, region)
  # end

  # test "returns an error if there was an issue connecting to Riot" do
  #   assert {:error, %Error{type: :data_fetch_error}} =
  #            SummonerTracker.get_summoner_opponent_history(name, region)
  # end

  test "handles bad input" do
    name = "austin#1234"
    assert_raise(ArgumentError, fn ->
      SummonerTracker.get_summoner_opponent_history(name, "foo")
    end)
  end
end
