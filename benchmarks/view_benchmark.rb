# frozen_string_literal: true

require "benchmark/ips"
require_relative "comparative/hanami"

Benchmarks::Comparative::Hanami.prepare

Benchmark.ips do |x|
  x.report("hanami/view") do
    Benchmarks::Comparative::Hanami.run
  end

  x.compare!
end
