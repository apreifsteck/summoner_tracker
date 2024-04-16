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

## Running
  ```shell
    export RIOT_API_KEY="your_api_key"
    mix deps.get
    iex -S mix
    iex(1)> SummonerTracker.get_summoner_opponent_history("<summoner_name>#<tagline>", "<region>")
  ```

## Considerations
  - What if we want to fetch a summoner by RiotID or other means in the future?
    - I created the `Summoner.SummonerQuery` for this purpose, that can have flexible
    internals.
  - What if we want to change the number of matches that we look back by?
    - I made this a parameter with a default value in the `RiotApi` that can be changed.
  - What if we want to change how often we poll or how long to poll for?
    - I actually took some liberty on this one, to add some jitter to the polling job
    to hopefully knock down the times that one might hit the rate limit and spread the load on 
    any third party servers.
  - What if we want to change how reports of summoner wins are created? 
    - I made a behaviour for this that I was able to use in some tests
  - What if we want to change how this project is run?
    - I tried not to make any assumptions about how this code might be embedded
    in a production environment, so I left it as a collection of modules that
    can be run in an iex shell.
  - Do we want to be able to monitor multiple Summoner's past opponents at once, or only one?
    - It seemed reasonable that we might want to do this for more than one summoner at a time.
    - I tend to err on the side of lighter weight solutions unless there is a demonstrative need
    for them, so I chose to use an in-memory solution. I couldn't find any libraries that would suite
    this purpose, so I rolled a simple job scheduler backed by a genserver and a task supervisor
      - Though I said I go for lighter weight solutions, some choices have a lot of bang
      for little cost. That's why I opted to use a `Task.Supervisor` for all concurrent operations.
  - Do our summoner monitoring activities need to survive system crashes or restarts?
    - Oban would be the obvious choice for this, however, adding a database for this sole reason
    would make logistics such as deployments more complex. Since crash resilience was not 
    stated in the requirements, I went with an in-memory job scheduler. However, I wrapped
    the job queueing semantics in an interface so that they could easily be changed later if necessary.
  - How do we balance rate limit concerns with speed?
    - There's a concurrency knob that you can turn in `config/config.exs` if you have a key with bigger
    rate limits. This, jitter on the job scheduler, and the auto-retries built into Req were enough 
    to keep things running smoothly. At larger scales I would probably like to revisit the current 
    architecture to build in a job pipeline with back pressure.

