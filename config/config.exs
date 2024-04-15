import Config

config :summoner_tracker, job_scheduler: SummonerTracker.Jobs.Scheduler
config :summoner_tracker, cache: Nebulex.Adapters.Local

import_config "#{config_env()}.exs"
