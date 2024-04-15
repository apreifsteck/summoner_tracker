defmodule SummonerTracker.NoficationAdapter do
  @moduledoc """
  An abstraction around sending any sort of event message to any sort of place.
  Could be a message bus, could be a message to another process, could be a callback url, or
  standard out. It doesn't matter.
  """

  @doc """
  Sends a string to the place the adapter is designed to put messages.
  In reality I would probably make a protocol with struct types to dynamiacally dispatch their payloads to the right place,
  but the only requirement in this project is to ship around strings, so that's what I have here.
  """
	@callback send(String.t()) :: :ok | {:error, any()}
end

defmodule SummonerTracker.NoficationAdapters.StdOut do
  @moduledoc """
  Sends string messages to standard out.
  """
	@behaviour SummonerTracker.NoficationAdapter

  def send(string) do
    IO.puts(string)
    :ok
  end
end

defmodule SummonerTracker.NoficationAdapters.Process do
  @moduledoc """
  Sends string messages to the current process. Mostly useful for testing.
  """
	
  def send(string) do
    send(self(), string)
  end
end
