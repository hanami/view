# frozen_string_literal: true

require "hotch"
require "pathname"
require "ostruct"
require "dry/view"

TEMPLATES_PATHS = Pathname(__FILE__).dirname.join("templates")

TEMPLATE_LOCALS = {
  users: [
    OpenStruct.new(name: "Jane", email: "Jane@example.com"),
    OpenStruct.new(name: "Teresa", email: "teresa@example.com")
  ]
}.freeze

class View < Dry::View
  config.paths = TEMPLATES_PATHS
  config.layout = "app"
  config.template = "users"

  expose :users
end

view = View.new

Hotch(filter: /View/) do
  100.times { view.(TEMPLATE_LOCALS).to_s }
end
