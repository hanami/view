# frozen_string_literal: true

require "benchmark/ips"
require_relative "comparative/hanami"
require_relative "comparative/rails"

Benchmarks::Comparative::Hanami.prepare
Benchmarks::Comparative::Rails.prepare

def normalize(str)
  str.gsub(/\s+/, " ")
end

outputs = {
  hanami: Benchmarks::Comparative::Hanami.run.then { normalize(_1) },
  rails: Benchmarks::Comparative::Rails.run.then { normalize(_1) },
}

if outputs.values.uniq.size > 1
  puts "Outputs do not match\n"

  outputs.each do |system, output|
    puts "#{system}:"
    puts output
  end
end

Benchmark.ips do |x|
  x.report("hanami/view") do
    Benchmarks::Comparative::Hanami.run
  end

  x.report("rails") do
    Benchmarks::Comparative::Hanami.run
  end

  x.compare!
end
