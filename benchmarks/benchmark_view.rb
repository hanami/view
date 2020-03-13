# frozen_string_literal: true

require "pathname"
require "ostruct"
require "benchmark/ips"
require "dry/view"
require "action_view"
require "action_controller"

TEMPLATES_PATHS = Pathname(__FILE__).dirname.join("templates")

TEMPLATE_LOCALS = {
  users: [
    OpenStruct.new(name: "Jane", email: "Jane@example.com"),
    OpenStruct.new(name: "Teresa", email: "teresa@example.com")
  ]
}.freeze

ActionController::Base.view_paths = TEMPLATES_PATHS

class UsersController < ActionController::Base
  layout "app"

  attr_reader :users

  def index
    @users = TEMPLATE_LOCALS[:users]
    render_to_string :index
  end
end

class DryView < Dry::View
  config.paths = TEMPLATES_PATHS
  config.layout = "app"
  config.template = "users"
  config.default_format = :html

  expose :users
end

action_controller = UsersController.new
dry_view = DryView.new

action_controller_output = action_controller.index
dry_view_output = dry_view.(TEMPLATE_LOCALS).to_s

if action_controller_output != dry_view_output
  puts "Output doesn't match:"
  puts
  puts "ActionView:\n\n#{action_controller_output}\n"
  puts "dry-view:\n\n#{dry_view_output}\n"
end

Benchmark.ips do |x|
  x.report("action_controller") do
    1000.times { action_controller.index }
  end

  x.report("dry-view") do
    1000.times { dry_view.(TEMPLATE_LOCALS).to_s }
  end

  x.compare!
end
