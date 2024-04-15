import Config

config :summoner_tracker,
  notification_adapter: SummonerTracker.NotificationAdapters.StdOut,
  job_scheduler: SummonerTracker.Jobs.Scheduler,
  cache: Nebulex.Adapters.Local,
  api_concurrency_opts: [max_concurrency: 1, timeout: 10_000]

import_config "#{config_env()}.exs"
