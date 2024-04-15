defmodule SummonerTracker.Tracker do
  alias SummonerTracker.{Summoner, Jobs}

  @callback track(summoner :: Summoner.t(), region :: String.t(), args :: map()) ::
              new_args :: map()

  @doc """
  There's a few ways we could go about this
  - We could have a specialized job queueing abstraction that looks to run a
  function continuously, holding state within the process
  - Run a function on an interval, passing the state from the last function call
  into the next somehow.
    - I like this one but I'm not sure how to do it 
    - kick off a task. This task will find the last 20(?) matches each player played.
      - Task will also include stop time.
    - Check if current time > stop time. If so, terminate
    - Else, schedule the next task to occur in one minute.
    - I could run this with Oban, but then I'd have to add a database,
      and I don't want to do that.
    - There are libraries like Quantum that could do this on a reliable
      schedule. The problem then is terminating them.
      - I could do that by doing like a
        "start no link sleep for an hour than run the kill function"
      - This has no way to get you to pass data from one function into another
    - I could have a genserver that recieves messages and uses that to 
      start dynamially supervised tasks
  """
  def attach_tracker_for(
        %Summoner{} = summoner,
        region,
        initial_state,
        tracker \\ __MODULE__.Trackers.NewMatchTracker,
        duration \\ :timer.hours(1),
        interval \\ :timer.minutes(1)
      ) do
    job_opts =
      Jobs.JobOpts.new!(
        execute_in: interval,
        halt_after: duration,
        state: initial_state
      )

    Jobs.add_job(
      fn
        state ->
          tracker.track(summoner, region, state)
      end,
      job_opts
    )
    :ok
  end
end
