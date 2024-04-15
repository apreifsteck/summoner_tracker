defmodule SummonerTracker.Summoner do
  @moduledoc """
  Represents a Summoner.
  This is probably obvious for everyone who would be looking at this module, but for those who aren't 
  versed in League of Legends (like me), a Summoner is the player.
  """
  use SummonerTracker.Schema

  defstruct do
    field(:game_name, :string)
    field(:tag_line, :string)
    field(:puuid, :string, required: true)
  end

  @spec riot_id(t()) :: String.t()
  def riot_id(%__MODULE__{} = self) do
    self.game_name <> "#" <> self.tag_line
  end
end

defmodule SummonerTracker.Summoner.SearchQuery do
  use SummonerTracker.Schema

  defstruct do
    field(:game_name, :string)
    field(:tag_line, :string)
    field(:puuid, :string)
    field(:region, :string, required: true)
  end

  @doc """
  Builds a Summoner Search Query from their riot id (game name + tag line).
  Expects the id to be in the form of "<game_name>#<tag_line>"
  """
  @spec from_riot_id(String.t(), String.t()) :: t()
  def from_riot_id(name, region) do
    case String.split(name, "#") do
      [name, tag_line] ->
        {:ok, __MODULE__.new!(%{game_name: name, tag_line: tag_line, region: region})}

      _ ->
        {:error,
         SummonerTracker.Error.new!(%{
           message: "invalid name",
           detail: "expected name in form of name#tagline, got: #{name}",
           type: :validation_error
         })}
    end
  end
end
