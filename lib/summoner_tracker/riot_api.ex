defmodule SummonerTracker.RiotApi do
  @moduledoc """
  A wrapper module around a few of riots API endpoints.
  Turns out Req handles retries for you if you hit the rate limit. Isn't that nice?
  """
  use Nebulex.Caching

  alias SummonerTracker.{Cache, Error, Match, Summoner}

  @doc """
  Gets a summoner by a `Summoner.SearchQuery`. This can be by puuid, name,
  or other attributes.
  """
  @spec get_summoner(Summoner.SearchQuery.t()) :: {:ok, Summoner.t()} | {:error, Error.t()}
  def get_summoner(query)

  def get_summoner(%Summoner.SearchQuery{puuid: id} = search_query) when not is_nil(id) do
    do_get_summoner("/by-puuid/#{id}", search_query.region)
  end

  def get_summoner(%Summoner.SearchQuery{game_name: name, tag_line: tag_line} = search_query) do
    do_get_summoner("/by-riot-id/#{name}/#{tag_line}", search_query.region)
  end

  @decorate cacheable(cache: Cache)
  defp do_get_summoner(uri, region) do
    request =
      uri
      |> URI.encode()
      |> get(api: :account, version: :v1, region: region)
      |> Req.Request.append_response_steps(snake_case_body: &snake_case_body/1)

    with {:ok, %{body: body} = resp} when is_map(body) and resp.status == 200 <-
           Req.request(request),
         {:ok, summoner} <- Summoner.new(body) do
      {:ok, summoner}
    else
      {:ok, %{body: body}} ->
        {:error, Error.new!(type: :downstream_server_error, detail: inspect(body))}

      {:error, %Ecto.Changeset{} = cs} ->
        {:error, Error.from_changeset(cs)}
    end
  end

  @doc """
  Match ids get returned in reverse chronological order.
  """
  @spec get_last_played_match_ids(Summoner.t(), integer()) ::
          {:ok, list(String.t())} | {:error, Error.t()}
  def get_last_played_match_ids(%Summoner{} = summoner, region, params \\ %{start: 0, count: 5}) do
    request =
      "/by-puuid/#{summoner.puuid}/ids"
      |> URI.new!()
      |> URI.append_query(URI.encode_query(params))
      |> get(api: :match, version: :v5, region: region)

    case Req.request(request) do
      {:ok, %{body: body} = resp} when is_list(body) and resp.status == 200 ->
        {:ok, body}

      {:ok, %{body: body} = resp} when resp.status !== 200 ->
        {:error, Error.new!(type: :downstream_server_error, detail: inspect(body))}

      {:ok, %{body: body}} ->
        {:error, Error.new!(type: :validation_error, detail: inspect(body))}
    end
  end

  @doc """
  return a `Match` given it's unique id
  """
  @decorate cacheable(cache: Cache)
  @spec get_match_by_id(id :: String.t(), region :: String.t()) ::
          {:ok, Match.t()} | {:error, Error.t()}
  def get_match_by_id(id, region) do
    request =
      "/#{id}"
      |> URI.new!()
      |> get(api: :match, version: :v5, region: region)

    with {:ok, %{body: body} = resp} when is_map(body) and resp.status == 200 <-
           Req.request(request),
         params = %{
           "participant_puuids" => body["metadata"]["participants"],
           "game_start_timestamp" => body["info"]["gameStartTimestamp"],
           "game_end_timestamp" => body["info"]["gameEndTimestamp"]
         },
         {:ok, match} <- Match.new(params) do
      {:ok, match}
    else
      {:ok, %{body: body}} ->
        {:error, Error.new!(type: :downstream_server_error, detail: inspect(body))}

      {:error, %Ecto.Changeset{} = cs} ->
        {:error, Error.from_changeset(cs)}
    end
  end

  defp get(url, template_options) do
    api = template_options[:api]

    api_extension =
      %{summoner: "summoners", match: "matches", account: "accounts"}[api]

    region = String.downcase(template_options[:region])

    game =
      case api do
        :account -> :riot
        _ -> :lol
      end

    base_url =
      "https://#{region}.api.riotgames.com/:game/:api/:version/:api_extension"

    Application.fetch_env!(:summoner_tracker, :riot_api_options)
    |> Keyword.merge(
      method: :get,
      base_url: base_url,
      url: url,
      path_params: template_options ++ [api_extension: api_extension, game: game]
    )
    |> Req.new()
  end

  defp snake_case_body({request, response}) when response.status == 200 do
    %{
      response
      | body: Utils.SnakeCasify.to_snake_case(response.body)
    }
    |> then(&{request, &1})
  end

  defp snake_case_body(request_and_response), do: request_and_response
end
