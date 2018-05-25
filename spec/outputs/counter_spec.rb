require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/counter"

LogStash::Logging::Logger::configure_logging("INFO")

Thread.abort_on_exception = true

describe LogStash::Outputs::Counter do

  subject do
    subj = described_class.new("warmup" => 0)
    subj.register
    subj
  end

  it "counts 10 events from 3 threads each" do
    object = Object.new
    t1 = Thread.new do
      10.times do
        subject.receive(object)
      end
    end
    t2 = Thread.new do
      10.times do
        subject.receive(object)
      end
    end
    t3 = Thread.new do
      10.times do
        subject.receive(object)
      end
    end
    t1.join
    t2.join
    t3.join
    expect(t1.alive?).to be_falsey
    expect(t2.alive?).to be_falsey
    expect(t3.alive?).to be_falsey
    expect(subject.measure.count).to eq(30)
    subject.close
  end

  it "counts 2 batches of 10 from 2 threads" do
    batch = []
    10.times { batch << Object.new }
    t1 = Thread.new do
      2.times do
        subject.multi_receive(batch)
      end
    end
    t2 = Thread.new do
      2.times do
        subject.multi_receive(batch)
      end
    end
    t1.join
    t2.join
    expect(t1.alive?).to be_falsey
    expect(t2.alive?).to be_falsey
    expect(subject.measure.count).to eq(40)
    subject.close
  end

  it "counts 2 batches of 10 from 2 threads, one output per thread" do
    out1 = described_class.new("warmup" => 0)
    out2 = described_class.new("warmup" => 0)
    out1.register
    out2.register

    batch = []
    10.times { batch << Object.new }
    t1 = Thread.new do
      2.times do
        out1.multi_receive(batch)
      end
    end
    t2 = Thread.new do
      2.times do
        out1.multi_receive(batch)
      end
    end
    t1.join
    t2.join
    expect(t1.alive?).to be_falsey
    expect(t2.alive?).to be_falsey
    expect(out1.measure.count).to eq(40)
    expect(out2.measure.count).to eq(40)
    out1.close
    out2.close
  end
end
