defmodule SummonerTracker.Cache do
	use Nebulex.Cache,
    otp_app: :summoner_tracker,
    adapter: Application.compile_env!(:summoner_tracker, :cache)
end
