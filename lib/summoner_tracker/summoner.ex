defmodule SummonerTracker.Summoner do
  use SummonerTracker.Schema

  defstruct do
    field(:game_name, :string)
    field(:tag_line, :string)
    field(:puuid, :string, required: true)
  end

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

  def from_name(name, region) do
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
