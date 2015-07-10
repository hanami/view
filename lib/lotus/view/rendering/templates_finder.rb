require 'lotus/view/template'

module Lotus
  module View
    module Rendering
      # Find templates for a view
      #
      # @api private
      # @since 0.1.0
      #
      # @see View::Template
      class TemplatesFinder
        # Default format
        #
        # @api private
        # @since 0.1.0
        FORMAT    = '*'.freeze

        # Default template engines
        #
        # @api private
        # @since 0.1.0
        ENGINES   = '*'.freeze

        # Recursive pattern
        #
        # @api private
        # @since 0.2.0
        RECURSIVE = '**'.freeze

        # Initialize a finder
        #
        # @param view [Class] the view
        #
        # @api private
        # @since 0.1.0
        def initialize(view)
          @view = view
        end

        # Find all the associated templates to the view.
        # It recursively looks for templates under the root path of the view,
        # that are matching the template name
        #
        # @return [Array<Lotus::View::Template>] the templates
        #
        # @api private
        # @since 0.1.0
        #
        # @see Lotus::View::Dsl#root
        # @see Lotus::View::Dsl#template
        #
        # @example
        #   require 'lotus/view'
        #
        #   module Articles
        #     class Show
        #       include Lotus::View
        #     end
        #   end
        #
        #   Articles::Show.root     # => "/path/to/templates"
        #   Articles::Show.template # => "articles/show"
        #
        #   # This view has a template:
        #   #
        #   #   "/path/to/templates/articles/show.html.erb"
        #
        #   Lotus::View::Rendering::TemplatesFinder.new(Articles::Show).find
        #     # => [#<Lotus::View::Template:0x007f8a0a86a970 ... @file="/path/to/templates/articles/show.html.erb">]
        def find
          _find.map do |template|
            View::Template.new(template)
          end
        end

        protected

        # @api private
        # @since 0.4.3
        def _find(lookup = search_path)
          Dir.glob( "#{ [root, lookup, template_name].join(separator) }.#{ format }.#{ engines }" )
        end

        # @api private
        # @since 0.1.0
        def template_name
          @view.template
        end

        # @api private
        # @since 0.1.0
        def root
          @view.root
        end

        # @api private
        # @since 0.4.3
        def search_path
          recursive
        end

        # @api private
        # @since 0.2.0
        def recursive
          RECURSIVE
        end

        # @api private
        # @since 0.1.0
        def separator
          ::File::SEPARATOR
        end

        # @api private
        # @since 0.1.0
        def format
          FORMAT
        end

        # @api private
        # @since 0.1.0
        def engines
          ENGINES
        end
      end
    end
  end
end
