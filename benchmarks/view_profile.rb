require "hotch"
require_relative "comparative/hanami"

Benchmarks::Comparative::Hanami.prepare

Hotch(filter: /Hanami::View/) do
  1000.times { Benchmarks::Comparative::Hanami.run }
end
