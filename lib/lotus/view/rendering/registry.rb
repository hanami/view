require 'pathname'
require 'tilt'
require 'lotus/view/rendering/registry/registration'

module Lotus
  module View
    module Rendering
      class Registry
        def initialize(view)
          @registry = _prepare(view)
        end

        def resolve(context)
          registry[context.format]
        end

        private
        attr_reader :registry

        def _prepare(view)
          Registration.new(view, Lotus::View.formats)
        end
      end
    end
  end
end
