require 'hanami/view/rendering/template_finder'

module Hanami
  module View
    module Rendering
      # Find a partial for the current view context.
      # It's used when a template wants to render a partial.
      #
      # @see Hanami::View::Rendering::Partial
      # @see Hanami::View::Rendering::TemplateFinder
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

        # Find a template for a partial. Initially it will look for the
        # partial template in the framework configuration where it may
        # already be cached. Failing that it will look under the
        # directory of the parent directory view template, if not found
        # it will search recursively from the view root.
        #
        # @return [Hanami::View::Template] the requested template
        #
        # @see Hanami::View::Rendering::TemplateFinder#find
        #
        # @since 0.4.3
        # @api private
        def find
          Hanami::View::Configuration.for(@view).
            find_partial(relative_partial_path, template_name, format)
        end

        protected

        # @since 0.7.0
        # @api private
        def relative_partial_path
          [view_template_dir, template_name].join(separator)
        end

        # @since 0.4.3
        # @api private
        def view_template_dir
          *all, _ = @view.template.split(separator)
          all.join(separator)
        end

        # @api private
        def template_name
          *all, last = partial_name.split(separator)
          all.push( last.prepend(prefix) ).join(separator)
        end

        # @api private
        def partial_name
          @options[:partial]
        end

        # @api private
        def prefix
          PREFIX
        end
      end
    end
  end
end
