defmodule SummonerTracker.ErrorTest do
  use SummonerTracker.Case, async: true
  alias SummonerTracker.Error
  alias Ecto.Changeset

  describe "from_changeset/1" do
    test "builds an error from a changeset" do
      assert %Error{type: :validation_error, message: ~s(%{data: ["is bad"]}), detail: ~s(%{data: %{}})} = 
      {%{data: %{}}, %{data: :map}}
      |> Changeset.change()
      |> Changeset.add_error(:data, "is bad")
      |> Error.from_changeset()
    end
  end
	
end

