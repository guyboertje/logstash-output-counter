# encoding: utf-8
require "concurrent"

module LogStash module Outputs
  class Measure
    def initialize(warmup)
      @warmup = warmup.to_f
      @counter = Concurrent::AtomicFixnum.new(0)
      @timers = Concurrent::Tuple.new(4)
      move_to_init
    end

    def increment(howmany = 1)
      now = Time.now.to_f
      if initial?
        move_to_warmup
        set_warmup_start(now)
      end

      if warmup? && warmup_timed_out?(now)
        move_to_counting
        set_counting_start(now)
      end

      if counting?
        @counter.increment(howmany)
        set_counting_end(now)
      end
    end

    def count
      @counter.value
    end

    def started_at
      @timers.get(0)
    end

    def finished_at
      @timers.get(1)
    end

    def count_duration
      finished_at - started_at
    end

    def report
      "Events per second: #{count} / #{count_duration} = #{count / count_duration}; microseconds per event: #{count_duration * 1000000 / count}"
    end

    private

    def initial?
      @timers.get(3) == 0
    end

    def warmup?
      @timers.get(3) == 1
    end

    def counting?
      @timers.get(3) == 2
    end

    def warmup_timed_out?(time)
      (time - warmup_started_at) > @warmup
    end

    def warmup_started_at
      @timers.get(2)
    end

    def move_to_init
      @timers.cas(3, nil, 0)
    end

    def move_to_warmup
      @timers.cas(3, 0, 1)
    end

    def move_to_counting
      @timers.cas(3, 1, 2)
    end

    def set_warmup_start(time)
      @timers.cas(2, nil, time)
    end

    def set_counting_start(time)
      @timers.cas(0, nil, time)
    end

    def set_counting_end(time)
      @timers.set(1, time)
    end

  end
end end
