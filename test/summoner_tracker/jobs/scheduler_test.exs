defmodule SummonerTracker.Jobs.SchedulerTest do
  use SummonerTracker.Case, async: true
  alias SummonerTracker.Jobs.Scheduler
  alias SummonerTracker.Jobs.JobOpts

  describe "add_job/2" do
    test "can schedule a job for some point in the future" do
      opts = JobOpts.new!(execute_in: 5)
      me = self()
      random_number = :rand.uniform()
      Scheduler.add_job(fn _ -> send(me, random_number) end, opts)

      refute_received ^random_number
      assert_receive ^random_number, 6
    end

    test "a job does not execute if it's halt time is less than the current time" do
      opts = JobOpts.new!(execute_in: 5, halt_at: System.monotonic_time(:millisecond) - 5)
      me = self()
      random_number = :rand.uniform()
      Scheduler.add_job(fn _ -> send(me, random_number) end, opts)

      refute_receive ^random_number, 7
    end

    test "a periodic job will stop executing if it's reached its halt time" do
      opts = JobOpts.new!(execute_every: 2, halt_after: 5)
      me = self()
      random_number = :rand.uniform()
      Scheduler.add_job(fn _ -> send(me, random_number) end, opts)
      assert_receive ^random_number, 3
      assert_receive ^random_number, 3
      refute_receive ^random_number, 3
    end

    test "a periodic job will send its return as input to the next occuring job" do
      me = self()
      my_number = 0
      opts = JobOpts.new!(execute_every: 2, halt_after: 7, state: my_number)
      Scheduler.add_job(fn num -> send(me, num + 1) end, opts)
      assert_receive 1, 3
      assert_receive 2, 3
      assert_receive 3, 3
    end
  end
end
