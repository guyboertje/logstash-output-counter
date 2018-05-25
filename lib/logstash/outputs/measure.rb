# encoding: utf-8
require "concurrent"

module LogStash module Outputs
  class Measure
    START = 0
    FINISH = 1
    WARMUP = 2
    STATE = 3

    S_INIT = 0
    S_WARMUP = 1
    S_COUNTING = 2

    def initialize(warmup)
      @warmup = warmup.to_f
      @counter = Concurrent::AtomicFixnum.new(0)
      @timers = Concurrent::Tuple.new(4)
      now = Time.now.to_f
      move_to_init
      if @warmup == 0.0
        move_to_warmup
        set_warmup_start(now)
        move_to_counting
        set_counting_start(now)
      end
    end

    def increment(howmany = 1)
      now = Time.now.to_f
      if counting?
        @counter.increment(howmany)
        set_counting_end(now)
      end

      if warmup? && warmup_timed_out?(now)
        move_to_counting
        set_counting_start(now)
      end

      if initial?
        move_to_warmup
        set_warmup_start(now)
      end
    end

    def count
      @counter.value
    end

    def started_at
      @timers.get(START)
    end

    def finished_at
      @timers.get(FINISH)
    end

    def count_duration
      finished_at - started_at
    end

    def report
      "Events per second: #{count} / #{count_duration} = #{count / count_duration}; microseconds per event: #{count_duration * 10**6 / count}"
    end

    private

    def initial?
      @timers.get(STATE) == S_INIT
    end

    def warmup?
      @timers.get(STATE) == S_WARMUP
    end

    def counting?
      @timers.get(STATE) == S_COUNTING
    end

    def warmup_timed_out?(time)
      (time - warmup_started_at) > @warmup
    end

    def warmup_started_at
      @timers.get(WARMUP)
    end

    def move_to_init
      @timers.cas(STATE, nil, S_INIT)
    end

    def move_to_warmup
      @timers.cas(STATE, S_INIT, S_WARMUP)
    end

    def move_to_counting
      @timers.cas(STATE, S_WARMUP, S_COUNTING)
    end

    def set_warmup_start(time)
      @timers.cas(WARMUP, nil, time)
    end

    def set_counting_start(time)
      @timers.cas(START, nil, time)
    end

    def set_counting_end(time)
      @timers.set(FINISH, time)
    end

  end
end end
