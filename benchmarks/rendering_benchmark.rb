# frozen_string_literal: true

require "pathname"
require "ostruct"
require "benchmark/ips"
require "hanami/view"

TEMPLATES_PATHS = Pathname(__FILE__).dirname.join("templates")

TEMPLATE_LOCALS = {
  users: [
    OpenStruct.new(name: "Jane", email: "jane@example.com"),
    OpenStruct.new(name: "Teresa", email: "teresa@example.com")
  ] * 50
}.freeze

class View < Hanami::View
  config.paths = TEMPLATES_PATHS
  config.layout = "app"
  config.template = "users"
  config.default_format = :html

  expose :users
end

view = View.new

Benchmark.ips do |x|
  x.report(ENV['BRANCH']) do
    100.times { view.(**TEMPLATE_LOCALS).to_s }
  end

  x.save! ENV['SAVE_FILE'] if ENV['SAVE_FILE']
  x.compare!
end
