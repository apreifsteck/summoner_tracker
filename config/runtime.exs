import Config

config :summoner_tracker,
  riot_api_options: [
    headers: %{"X-Riot-Token" => System.fetch_env!("RIOT_API_KEY")}
  ]
