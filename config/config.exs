import Config

config :summoner_tracker, cache: Nebulex.Adapters.Local

import_config "#{config_env()}.exs"
