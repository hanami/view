require 'lotus/utils/string'

module Lotus
  module View
    module Rendering
      class LayoutFinder
        def self.find(layout)
          case layout
          when Symbol, String
            class_name = "#{ Utils::String.new(layout).classify }Layout"
            Object.const_get(class_name)
          when nil
            Lotus::View.layout
          end
        end

        def initialize(view)
          @view = view
        end

        def find
          self.class.find(@view.layout)
        end
      end
    end
  end
end
