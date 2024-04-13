import Config

config :summoner_tracker, cache: Nebulex.Adapters.Nil

config :summoner_tracker,
  riot_api_options: [
    plug: {Req.Test, SummonerTracker.RiotApi},
    retry: false
  ]
