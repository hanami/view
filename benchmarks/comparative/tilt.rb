require "tilt"
require "ostruct"

module Benchmarks
  module Comparative
    module Tilt
      LOCALS = {
        users: [
          OpenStruct.new(name: "Jane", email: "jane@example.com"),
          OpenStruct.new(name: "Teresa", email: "teresa@example.com")
        ]
      }.freeze

      TEMPLATES_PATH = File.expand_path(File.join(__dir__, "tilt", "templates")).freeze

      class Scope
        def initialize
          @templates = {}
        end

        def render(partial_name, **locals)
          _partial_template(partial_name).render(self, locals)
        end

        private

        def _partial_template(partial_name)
          @templates.fetch(partial_name) {
            @templates[partial_name] = ::Tilt.new(File.join(TEMPLATES_PATH, "_#{partial_name}.html.erb"))
          }
        end
      end

      def self.prepare
        @scope = Scope.new
        @layout = ::Tilt.new(File.join(TEMPLATES_PATH, "app.html.erb"))
        @template = ::Tilt.new(File.join(TEMPLATES_PATH, "users.html.erb"))
      end

      def self.run
        @layout.render(@scope) { @template.render(@scope, LOCALS) }
      end
    end
  end
end
