defmodule SummonerTracker.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {SummonerTracker.Cache, []},
      SummonerTracker.Jobs.Scheduler,
      {Task.Supervisor, name: SummonerTracker.Jobs.Scheduler.TaskSupervisor},
      {Task.Supervisor, name: SummonerTracker.ApiTaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: RfcApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
