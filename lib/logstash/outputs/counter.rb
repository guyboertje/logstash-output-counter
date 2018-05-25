# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require "logstash/outputs/measure"

# require "concurrent"

# A counter output. This is useful for testing logstash inputs and filters for
# performance. Pair with the generator input that has had the time modification
# to measure filter performance

module LogStash module Outputs class Counter < LogStash::Outputs::Base
  concurrency :shared

  config_name "counter"

  # Set how long this output wait before beginning measurements.
  #
  # The default, `20`, means 20 seconds.
  config :warmup, :validate => :number, :default => 20

  def self.measure
    @measure
  end

  def self.setup(warmup)
    @measure = Measure.new(warmup.to_f)
  end

  def register
    self.class.setup(@warmup)
  end

  def receive(event)
    measure.increment
  end

  def multi_receive(events)
    measure.increment(events.size)
  end

  def measure
    self.class.measure
  end

  def close
    logger.info("Benchmark report: " + self.class.measure.report)
  end
end end end
