require "action_view"
require "action_controller"
require "ostruct"

module Benchmarks
  module Comparative
    module Rails
      class UsersController < ActionController::Base
        self.view_paths = File.expand_path(File.join(__dir__, "rails", "templates"))

        layout "app"

        def index
          @users = LOCALS[:users]
          render_to_string "users/index"
        end
      end

      LOCALS = {
        users: [
          OpenStruct.new(name: "Jane", email: "jane@example.com"),
          OpenStruct.new(name: "Teresa", email: "teresa@example.com")
        ]
      }.freeze

      def self.prepare
        @controller = UsersController.new
      end

      def self.run
        @controller.index
      end
    end
  end
end
