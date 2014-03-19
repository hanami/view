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
        FORMAT  = '*'.freeze
        ENGINES = '*'.freeze

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
        # It looks for templates under the root path of the view, that are
        # matching the template name
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
          Dir.glob( "#{ [root, template_name].join(separator) }.#{ format }.#{ engines }" ).map do |template|
            View::Template.new template
          end
        end

        protected
        def template_name
          @view.template
        end

        def root
          @view.root
        end

        def separator
          ::File::SEPARATOR
        end

        def format
          FORMAT
        end

        def engines
          ENGINES
        end
      end
    end
  end
end
