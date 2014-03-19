require 'lotus/view/rendering/templates_finder'

module Lotus
  module View
    module Rendering
      # Find a template for the current view context.
      # It's used when a template wants to render another template.
      #
      # @see Lotus::View::Rendering::Template
      # @see Lotus::View::Rendering::TemplatesFinder
      #
      # @api private
      # @since 0.1.0
      class TemplateFinder < TemplatesFinder
        # Initialize a finder
        #
        # @param view [Class] a view
        # @param options [Hash] the informations about the context
        # @option options [String] :template the template file name
        # @option options [Symbol] :format the requested format
        #
        # @api private
        # @since 0.1.0
        def initialize(view, options)
          super(view)
          @options = options
        end

        # Find a template for the current view context
        #
        # @return [Lotus::View::Template] the requested template
        #
        # @api private
        # @since 0.1.0
        #
        # @see Lotus::View::Rendering::TemplatesFinder#find
        # @see Lotus::View::Rendering::Template#render
        def find
          super.first
        end

        protected
        def template_name
          @options[:template]
        end

        def format
          @options[:format]
        end
      end
    end
  end
end
