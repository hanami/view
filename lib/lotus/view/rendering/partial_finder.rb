require 'lotus/view/rendering/template_finder'

module Lotus
  module View
    module Rendering
      class PartialFinder < TemplateFinder
        PREFIX = '_'.freeze

        protected
        def template_name
          *all, last = partial_name.split(separator)
          all.push( last.prepend(prefix) ).join(separator)
        end

        def partial_name
          @options[:partial]
        end

        def prefix
          PREFIX
        end
      end
    end
  end
end
