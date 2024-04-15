defmodule SummonerTracker.Match do
  @moduledoc """
  A game that's been played in League of Legends
  """
  use Strukt

  @primary_key false
  defstruct do
    field(:participant_puuids, {:array, :string}, required: true)
    field(:game_start_timestamp, :integer, required: true)
    field(:game_end_timestamp, :integer, required: true)
  end
end
