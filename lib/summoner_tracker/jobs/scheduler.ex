defmodule SummonerTracker.Jobs.Scheduler do
  @moduledoc """
  A relatively basic job scheduler using a `GenServer` + `Task.Supervisor`.
  It has a few unique properties that made it necessary for this task:
  1. It can halt a periodic job after a given period of time
  2. Periodic jobs are linked together; a preceding job's output is used as the input arg to the next run of that job
  I couldn't find a library that did both of those things, so here we are.

  One thing that I would want to build in in a production setting would be the ability to retry jobs that terminate abnormally.
  That's not built in here as it would definitely be over-engineering this.
  """
  use GenServer

  require Logger

  @behaviour SummonerTracker.Jobs
  @task_supervisor SummonerTracker.Jobs.Scheduler.TaskSupervisor

  alias SummonerTracker.Jobs.JobOpts

  @impl GenServer
  def init(_) do
    {:ok, []}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl SummonerTracker.Jobs
  def add_job(func, %JobOpts{halt_at: nil, halt_after: time} = job_opts) when not is_nil(time) do
    job_opts = %JobOpts{job_opts | halt_at: system_time() + time}
    GenServer.cast(__MODULE__, {:schedule_job, func, job_opts, 0})
  end

  def add_job(func, job_opts) do
    GenServer.cast(__MODULE__, {:schedule_job, func, job_opts, 0})
  end

  @impl GenServer
  def handle_cast({:schedule_job, func, job_opts, prev_job_duration}, _state) do
    if job_opts.halt_at > system_time() do
      jitter = Enum.random(job_opts.jitter) 
      case job_opts do
        %JobOpts{execute_every: time} when not is_nil(time) ->
          # Attempts to correct for previous job's execution time to
          # stick to the given schedule
          schedule_in = max((time - prev_job_duration) + jitter, 0)
          Process.send_after(self(), {:start_job, func, job_opts}, schedule_in)

        %JobOpts{execute_in: time} when not is_nil(time) ->
          Process.send_after(self(), {:start_job, func, job_opts}, time + jitter)
      end
    end

    {:noreply, nil}
  end

  @impl GenServer
  def handle_info({:start_job, func, job_opts}, _) do
    Task.Supervisor.async_nolink(@task_supervisor, fn ->
      new_state = func.(job_opts.state)
      start_time = system_time()
      new_opts = JobOpts.set_state(job_opts, new_state)

      end_time = system_time()
      duration = end_time - start_time
      # this thruple will get passed to the handle_info call when the task completes
      {func, new_opts, duration}
    end)

    {:noreply, nil}
  end

  # The job completed successfully
  def handle_info({ref, {func, %JobOpts{execute_every: time} = job_opts, job_duration}}, _)
      when not is_nil(time) do
    GenServer.cast(__MODULE__, {:schedule_job, func, job_opts, job_duration})
    Process.demonitor(ref, [:flush])
    {:noreply, nil}
  end

  def handle_info({ref, _answer}, _) do
    Process.demonitor(ref, [:flush])
    {:noreply, nil}
  end

  # The job failed
  def handle_info({:DOWN, _ref, :process, _pid, reason}, _) do
    Logger.error("Job failed with reason: #{reason}")
    {:noreply, nil}
  end

  defp system_time do
    System.monotonic_time(:millisecond)
  end
end
