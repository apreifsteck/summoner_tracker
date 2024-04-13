defmodule Utils.SnakeCasify do
  def to_snake_case(map) when is_map(map) do
    map
    |> Enum.map(fn {k, v} -> {to_snake_case(k), v} end)
    |> Map.new()
  end

  defdelegate to_snake_case(str), to: Macro, as: :underscore
end
