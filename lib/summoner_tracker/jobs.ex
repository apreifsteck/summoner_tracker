defmodule SummonerTracker.Jobs do
  @moduledoc """
  a behaviour around executing work at a particular point in time.
  Meant as a generic interface around deferred work so that the 
  implementation can be swapped out later if required.
  """
  alias SummonerTracker.Jobs.JobOpts

  @callback add_job((any() -> any()), JobOpts.t()) :: :ok

  @implementation Application.compile_env!(:summoner_tracker, :job_scheduler)

  defdelegate add_job(func, opts), to: @implementation
end

defmodule SummonerTracker.Jobs.JobOpts do
  @moduledoc """
  Options around when to start and stop deferred work.

  Struct fields:
  `execute_in`: time in milliseconds from now that the job should run
  `execute_every`: time T in milliseconds from now that the job should run.
    - After the job is run, it will attempt to run again after T milliseconds
      after the previous job *started*. This means if the previous job
      took longer than T, the next job will execute immediately.
    - Note that the only way to stop a periodic job is by configuring
      `halt_at` or `halt_after`
  `halt_at`: a particular time to stop at. Current implementation uses system time.
  `halt_after`: A duration in milliseconds after which the job should no longer be run.
    - Exact halt time calculated when the job is first scheduled
  `jitter`: add some randomness to when the job is scheduled. Should be a range of integers in milliseconds.

  Note: 
  - The halting options are really only useful for periodic jobs.
  - Neither of the halting options will stop a job that's currently in progress.
  """
  use SummonerTracker.Schema
  alias Ecto.Changeset
  # todo, make halt_at and halt after mutually exclusive
  # make execute_in and execute every mutually exclusive

  defstruct do
    field(:execute_in, :integer)
    field(:execute_every, :integer)
    field(:halt_at, :integer)
    field(:halt_after, :integer)
    field(:jitter, :any, default: [0], virtual: true)
    # I'm not using a db so this doesn't matter
    # I need it for the underlying ecto lib to be happy though
    field(:state, :any, virtual: true)
  end

  def validate(changeset) do
    changeset
    |> Changeset.validate_change(:execute_in, fn _, _time ->
      mutually_exclusive(changeset.changes, :execute_in, :execute_every)
    end)
    |> Changeset.validate_change(:halt_at, fn _, _time ->
      mutually_exclusive(changeset.changes, :halt_at, :halt_after)
    end)
  end

  defp mutually_exclusive(changes, field_one, field_two) do
    if Map.has_key?(changes, field_two) do
      [{field_one, "#{field_one} is mutually exclusive with #{field_two}"}]
    else
      []
    end
  end

  def halt_after(%__MODULE__{} = self, milliseconds_from_now) do
    %__MODULE__{self | halt_at: System.monotonic_time(:milisecond) + milliseconds_from_now}
  end

  def set_state(%__MODULE__{} = self, state) do
    %__MODULE__{self | state: state}
  end
end
