defmodule SummonerTracker.RiotApi.MockAdapter do
  def setup_default_stub() do
    Req.Test.stub(SummonerTracker.RiotApi, fn conn ->
      path_contains? = &String.contains?(conn.request_path, &1)

      cond do
        path_contains?.("/accounts/by-riot-id") ->
          [name, tag_line] =
            conn.path_info
            |> Enum.reverse()
            |> Enum.take(2)
            |> Enum.reverse()

          Req.Test.json(conn, summoner_resp(name, tag_line))

        path_contains?.("/matches/by-puuid") ->
          Req.Test.json(conn, matches_resp())

        path_contains?.("/matches") ->
          Req.Test.json(conn, match_resp())
      end
    end)
  end

  defp summoner_resp(name, tag_line) do
    %{
      puuid: :crypto.strong_rand_bytes(100) |> Base.encode64() |> String.slice(0..77),
      gameName: name,
      tagLine: tag_line
    }
  end

  defp matches_resp() do
    ["BR1_2922187228", "BR1_2922175461", "BR1_2922157850", "BR1_2922148640", "BR1_2922136701"]
  end

  defp match_resp() do
    File.read!("test/support/fixtures/matches/success.json") |> Jason.decode!()
  end
end
