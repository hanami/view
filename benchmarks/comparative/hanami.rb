require "hanami/view"
require "ostruct"

module Benchmarks
  module Comparative
    module Hanami
      class View < ::Hanami::View
        config.paths = File.expand_path(File.join(__dir__, "hanami", "templates"))
        config.layout = "app"
        config.template = "users"
        config.default_format = :html

        expose :users
      end

      LOCALS = {
        users: [
          OpenStruct.new(name: "Jane", email: "jane@example.com"),
          OpenStruct.new(name: "Teresa", email: "teresa@example.com")
        ]
      }.freeze

      def self.prepare
        @view = View.new
      end

      def self.run
        @view.call(**LOCALS).to_s
      end
    end
  end
end
