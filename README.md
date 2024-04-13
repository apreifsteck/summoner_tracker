# SummonerTracker
## Requirements
  Create a mix project application that: 
  - Given a valid summoner_name and region will fetch all summoners this summoner has played with in the last 5 matches.
  This data is returned to the caller as a list of summoner names (see below). Also, the following occurs: 

  - Once fetched, all summoners will be monitored for new matches every minute for the next hour 
    - When a summoner plays a new match, the match id is logged to the console, such as: 
    - `Summoner <summoner name> completed match <match id>`
  The returned data should be formatted as: 
  ```elixir
  [summoner_name_1, summoner_name_2, ...] 
  ```
  - Please upload this project to Github and send us the link. 
  Notes: 
  - Make use of Riot Developer API 
    - https://developer.riotgames.com/apis 
    - https://developer.riotgames.com/apis#summoner-v4 
    - https://developer.riotgames.com/apis#match-v5 
  - You will have to generate an api key. Please make this configurable so we can substitute our own key in order to test.


## Considerations
  - What if we want to fetch a summoner by RiotID or other means in the future?
  - What if we want to change the number of matches that we look back by?
  - What if we want to change how often we poll or how long to poll for?
  - What if we want to change how reports of summoner wins are created? 
    - or where they are reported to?
  - What if we want to change how this project is run?
    - Make it part of a web service, for example?
  - Do we want to be able to monitor multiple Summoner's past opponents at once, or only one?
  - Do our summoner monitoring activities need to survive system crashes or restarts?

## Running
  - Set your Riot API key to the environment variable `RIOT_API_KEY`
