# frozen_string_literal: true

require "benchmark/ips"
require_relative "comparative/hanami"

Benchmarks::Comparative::Hanami.prepare

Benchmark.ips do |x|
  x.report(ENV.fetch("BENCHMARK_NAME", "hanami/view")) do
    Benchmarks::Comparative::Hanami.run
  end

  x.save! ENV["SAVE_FILE"] if ENV["SAVE_FILE"]
  x.compare!
end
