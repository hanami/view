require 'lotus/view/rendering/template_finder'

module Lotus
  module View
    module Rendering
      # Find a partial for the current view context.
      # It's used when a template wants to render a partial.
      #
      # @see Lotus::View::Rendering::Partial
      # @see Lotus::View::Rendering::TemplateFinder
      #
      # @api private
      # @since 0.1.0
      class PartialFinder < TemplateFinder
        # Template file name prefix.
        # By convention a partial file name starts with this prefix.
        #
        # @api private
        # @since 0.1.0
        #
        # @example
        #   "_sidebar.html.erb"
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
