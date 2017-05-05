require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/counter"

describe LogStash::Outputs::Counter do

  subject do
    subj = described_class.new
    subj.register
    subj
  end

  it "counts 30 events from 3 threads" do
    t1 = Thread.new do
      10.times do
        subject.receive(Object.new)
      end
    end
    t2 = Thread.new do
      10.times do
        subject.receive(Object.new)
      end
    end
    t3 = Thread.new do
      10.times do
        subject.receive(Object.new)
      end
    end
    t1.join; t2.join; t3.join

    expect(subject.count).to eq(30)
  end

  it "counts batches from multiple threads" do
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
    t1.join; t2.join

    expect(subject.count).to eq(40)
  end
end
