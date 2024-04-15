import Config

config :summoner_tracker,
  riot_api_options: [
    plug: {Req.Test, SummonerTracker.RiotApi},
    retry: false
  ],
  cache: Nebulex.Adapters.Nil,
  api_concurrency_opts: [max_concurrency: 10, timeout: 10_000]
