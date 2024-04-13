defmodule SummonerTracker.Error do
  use SummonerTracker.Schema

  alias Ecto.Changeset

  @error_types ~w(
    network_error
    downstream_server_error
    validation_error
  )a

  defstruct do
    field(:type, Ecto.Enum, values: @error_types, required: true)
    field(:message, :string)
    field(:detail, :string)
  end

  def from_changeset(%Changeset{valid?: false} = cs) do
    cs
    |> Changeset.traverse_errors(fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
    |> then(&%{message: inspect(&1), type: :validation_error, detail: inspect(cs.data)})
    |> __MODULE__.new!()
  end
end
