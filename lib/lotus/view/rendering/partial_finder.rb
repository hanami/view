require 'lotus/view/rendering/template_finder'

module Lotus
  module View
    module Rendering
      class PartialFinder < TemplateFinder
        PREFIX = '_'.freeze

        def initialize(view, partial_name)
          super(view, nil)
          @partial_name = partial_name
        end

        protected
        def template_name
          "#{ _prefixed_file_name }.#{ format }"
        end

        def format
          view.format || super
        end

        def prefix
          PREFIX
        end

        def _prefixed_file_name
          *all, last = @partial_name.split(separator)
          all.push( last.prepend(prefix) ).join(separator)
        end
      end
    end
  end
end
