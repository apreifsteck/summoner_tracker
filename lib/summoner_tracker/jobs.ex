defmodule SummonerTracker.Jobs do
  @moduledoc """
  a behaviour around executing work at a particular point in time.
  Meant as a generic interface around deferred work so that the 
  implementation can be swapped out later if required.
  """
  use SummonerTracker.Schema
  alias SummonerTracker.Jobs.JobOpts

  @callback add_job(function(), JobOpts.t()) :: :ok

  @implementation Application.compile_env!(:summoner_tracker, :job_scheduler)

  defdelegate add_job(func, opts), to: @implementation
end

defmodule SummonerTracker.Jobs.Job do
  @moduledoc """
  Options around when to start and stop deferred work.
  """
  use SummonerTracker.Schema

  defstruct do
    # I'm not using a db so this doesn't matter
    # I need it for the underlying ecto lib to be happy though
    field(:pid, :any, required: true, virtual: true)
  end

  def validate(changeset) do
    Ecto.Changeset.validate_change(changeset, :pid, fn field, pid -> 
      if is_pid(pid) do
        []
      else
        [{field, "must be pid, got: #{inspect(pid)}"}]
      end
    end)
  end
end

defmodule SummonerTracker.Jobs.JobOpts do
  @moduledoc """
  Options around when to start and stop deferred work.
  """
  use SummonerTracker.Schema
  # todo, make halt_at and halt after mutually exclusive
  # make execute_in and execute every mutually exclusive

  defstruct do
    field(:execute_in, :integer)
    field(:execute_every, :integer)
    field(:halt_at, :integer)
    field(:halt_after, :integer)
    # I'm not using a db so this doesn't matter
    # I need it for the underlying ecto lib to be happy though
    field(:state, :any, virtual: true)
  end

  def halt_after(%__MODULE__{} = self, milisenonds_from_now) do
    %__MODULE__{self | halt_at: System.monotonic_time(:milisecond) + milisenonds_from_now}
  end

  def set_state(%__MODULE__{} = self, state) do
    %__MODULE__{self | state: state}
  end
end
