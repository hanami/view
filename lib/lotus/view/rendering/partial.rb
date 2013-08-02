require 'lotus/view/rendering/partial_finder'

module Lotus
  module View
    module Rendering
      class Partial < Template
        protected
        def template
          PartialFinder.new(view.class, options[:partial]).find
        end
      end
    end
  end
end
