require "benchmark/ips"
require_relative "comparative/hanami"
require_relative "comparative/rails"
require_relative "comparative/tilt"

Benchmarks::Comparative::Hanami.prepare
Benchmarks::Comparative::Rails.prepare
Benchmarks::Comparative::Tilt.prepare

def normalize(str)
  str.gsub(/\s+/, " ")
end

outputs = {
  hanami: Benchmarks::Comparative::Hanami.run,
  rails: Benchmarks::Comparative::Rails.run,
  tilt: Benchmarks::Comparative::Tilt.run,
}

if outputs.values.map { normalize(_1) }.uniq.size > 1
  puts "Outputs do not match\n"

  outputs.each do |system, output|
    puts "#{system}:"
    puts normalize(output)
  end
end

Benchmark.ips do |x|
  x.report("hanami/view") do
    Benchmarks::Comparative::Hanami.run
  end

  x.report("rails") do
    Benchmarks::Comparative::Rails.run
  end

  x.report("tilt") do
    Benchmarks::Comparative::Tilt.run
  end

  x.compare!
end
