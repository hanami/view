require 'hanami/view/rendering/partial_finder'

module Hanami
  module View
    module Rendering
      # Rendering partial
      #
      # It's used when a template wants to render a partial.
      #
      # @api private
      # @since 0.1.0
      #
      # @see Hanami::View::Rendering::Template
      # @see Hanami::View::Rendering::LayoutScope#render
      #
      # @example
      #   # We have an application template (templates/application.html.erb)
      #   # that uses the following line:
      #
      #   <%= render partial: 'shared/sidebar' %>
      class Partial < Template
        protected
        def template
          PartialFinder.new(@view.class, @options).find
        end
      end
    end
  end
end
