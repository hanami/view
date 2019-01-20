# frozen_string_literal: true

require 'hotch'
require 'pathname'
require 'ostruct'
require 'dry/view/controller'

TEMPLATES_PATHS = Pathname(__FILE__).dirname.join('templates')

TEMPLATE_LOCALS = { users: [
  OpenStruct.new(name: 'Jane', email: 'Jane@example.com'),
  OpenStruct.new(name: 'Teresa', email: 'teresa@example.com')
] }

class Controller < Dry::View
  config.paths = TEMPLATES_PATHS
  config.layout = 'app'
  config.template = 'users'

  expose :users
end

controller = Controller.new

Hotch(filter: /View/) do
  100.times { controller.(TEMPLATE_LOCALS).to_s }
end
