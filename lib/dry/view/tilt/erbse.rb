require "tilt/template"
require "erbse"

module Dry
  module View
    module Tilt
      # Tilt template class copied from cells-erb gem
      class ErbseTemplate < ::Tilt::Template
        def prepare
          @template = ::Erbse::Engine.new
        end

        def precompiled_template(locals)
          @template.call(data)
        end
      end
    end
  end
end
