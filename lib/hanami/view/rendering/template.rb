require 'hanami/view/rendering/template_finder'

module Hanami
  module View
    module Rendering
      # Rendering template
      #
      # It's used when a template wants to render another template.
      #
      # @api private
      # @since 0.1.0
      #
      # @see Hanami::View::Rendering::LayoutScope#render
      #
      # @example
      #   # We have an application template (templates/application.html.erb)
      #   # that uses the following line:
      #
      #   <%= render template: 'articles/show' %>
      class Template
        # Initialize a template
        #
        # @param view [Hanami::View] the current view
        # @param options [Hash] the rendering informations
        # @option options [Symbol] :format the current format
        # @option options [Hash] :locals the set of objects available within
        #   the rendering context
        #
        # @api private
        # @since 0.1.0
        def initialize(view, options)
          @view, @options = view, options
        end

        # Render the template.
        #
        # @return [String] the output of the rendering process.
        #
        # @raise [Hanami::View::MissingTemplateError] if template can't be found
        #
        # @api private
        # @since 0.1.0
        def render
          (template or raise_missing_template_error).render(scope)
        end

        protected
        # @api private
        def template
          TemplateFinder.new(@view.class, @options).find
        end

        # @api private
        def scope
          Subscope.new(@view, @options[:locals])
        end

        # @since 0.5.0
        # @api private
        def raise_missing_template_error
          raise MissingTemplateError.new(
            @options.fetch(:template) { @options.fetch(:partial, nil) },
            @options[:format]
          )
        end
      end
    end
  end
end
