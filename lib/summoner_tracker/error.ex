defmodule SummonerTracker.Error do
  @moduledoc """
  Represents any error that can happen in this toy app.
  I've found this generic error pattern quite useful in practice.
  """
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

  @spec from_changeset(Ecto.Changeset.t()) :: t()
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
