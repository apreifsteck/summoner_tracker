defmodule SummonerTracker.Schema do
  defmacro __using__(_opts) do
    quote do
      use Strukt

      @primary_key false

      def new!(attrs) do
        attrs
        |> __MODULE__.new()
        |> case do
          {:ok, struct} -> struct
          {:error, changeset} -> raise ArgumentError, message: inspect(changeset)
        end
      end
    end
  end
end
