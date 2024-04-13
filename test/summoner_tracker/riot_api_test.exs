defmodule SummonerTracker.RiotApiTest do
  use ExUnit.Case, async: true
  alias SummonerTracker.{Error, Match, RiotApi, Summoner}

  @valid_summoner_attrs %{
    "puuid" => "JG4GTcFvs3FgP2DFNttz-k18RPQVzqzEpHqgThzz4FgQMgkaPCOSsDOILpwLKBOAjh-6AL7BpnpiiQ",
    "gameName" => "Majesty",
    "tagLine" => "duda"
  }

  describe "get_summoner/1 - happy path" do
    setup do
      query = Summoner.SearchQuery.new!(name: "foo", tag_line: "bar", region: "bar")
      {:ok, query: query}
    end

    test "fetches a summoner based on a summoner query", context do
      Req.Test.stub(RiotApi, fn conn ->
        assert String.contains?(conn.request_path, "/by-")

        Req.Test.json(conn, @valid_summoner_attrs)
      end)

      assert {:ok, %Summoner{}} = RiotApi.get_summoner(context.query)
    end
  end

  describe "get_last_played_match_ids/3" do
    setup do
      summoner = @valid_summoner_attrs |> Utils.SnakeCasify.to_snake_case() |> Summoner.new!()
      {:ok, summoner: summoner}
    end

    test "fetches a list of match ids given a summoner", context do
      expected_match_ids = ~w(
          "BR1_2922187228"
          "BR1_2922175461"
          "BR1_2922157850"
          "BR1_2922148640"
          "BR1_2922136701"
        )

      Req.Test.stub(RiotApi, fn conn ->
        assert String.contains?(conn.request_path, "/matches/by-puuid")

        Req.Test.json(conn, expected_match_ids)
      end)

      assert {:ok, ^expected_match_ids} =
               RiotApi.get_last_played_match_ids(context.summoner, "AMERICAS")
    end
  end

  describe "get_match_by_id/2" do
    test "returns a match given a valid id" do
      match_id = "BR1_2922187228"

      Req.Test.stub(RiotApi, fn conn ->
        assert String.contains?(conn.request_path, "/matches/#{match_id}")

        resp = File.read!("test/support/fixtures/matches/success.json") |> Jason.decode!()
        Req.Test.json(conn, resp)
      end)

      assert {:ok, %Match{}} =
               RiotApi.get_match_by_id(match_id, "AMERICAS")
    end
  end

  describe "sad path - all functions" do
    for {f, a} <- [
          {:get_summoner, [Summoner.SearchQuery.new!(account_id: "foo", region: "bar")]},
          {:get_last_played_match_ids,
           [
             @valid_summoner_attrs |> Utils.SnakeCasify.to_snake_case() |> Summoner.new!(),
             "AMERICAS"
           ]},
          {:get_match_by_id, ["BR1_2922187228", "AMERICAS"]}
        ] do
      @tag f: f, a: a
      test "returns an error if there was a problem parsing the body in function #{f}", %{
        f: f,
        a: a
      } do
        Req.Test.stub(RiotApi, fn conn ->
          Req.Test.json(conn, %{
            foo: 1234
          })
        end)

        assert {:error, %Error{type: :validation_error}} = apply(RiotApi, f, a)
      end

      @tag f: f, a: a
      test "returns an error if there was a non-200 from the server for function #{f}", %{
        f: f,
        a: a
      } do
        Req.Test.stub(RiotApi, fn conn ->
          Plug.Conn.send_resp(conn, 500, "Error")
        end)

        assert {:error, %Error{type: :downstream_server_error}} = apply(RiotApi, f, a)
      end
    end
  end
end
