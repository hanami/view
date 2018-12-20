# frozen_string_literal: true

require 'pathname'
require 'ostruct'
require 'benchmark/ips'
require 'dry/view/controller'
require 'action_view'
require 'action_controller'

TEMPLATES_PATHS = Pathname(__FILE__).dirname.join('templates')

users = [
  OpenStruct.new(name: 'John', link: 'john@google.com`'),
  OpenStruct.new(name: 'Teresa', link: 'teresa@google.com`')
]

ActionController::Base.view_paths = TEMPLATES_PATHS

class UsersController < ActionController::Base
  layout "app"

  def index
    @users = [
      OpenStruct.new(name: 'John', link: 'john@google.com`'),
      OpenStruct.new(name: 'Teresa', link: 'teresa@google.com`')
    ]
    render_to_string :index
  end
end

class DryViewController < Dry::View::Controller
  configure do |config|
    config.paths = TEMPLATES_PATHS
    config.layout = 'app'
    config.template = 'users'
    config.default_format = :html
  end

  expose :users
end

action_controller = UsersController.new
dry_view_controller = DryViewController.new

Benchmark.ips do |x|
  x.report('action_controller') do
    action_controller.index
  end
  x.report('dry-view') { dry_view_controller.(users: users) }
  x.compare!
end
