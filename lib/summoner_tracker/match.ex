defmodule SummonerTracker.Match do
  use Strukt

  @primary_key false
  defstruct do
    field(:participant_puuids, {:array, :string}, required: true)
    field(:game_start_timestamp, :integer, required: true)
    field(:game_end_timestamp, :integer, required: true)
  end
end
