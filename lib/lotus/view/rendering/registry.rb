require 'lotus/view/rendering/layout_registry'
require 'lotus/view/rendering/view_finder'
require 'lotus/view/rendering/null_view'

module Lotus
  module View
    module Rendering
      # Holds all the references of all the registered subclasses of a view.
      # We have one registry for each superclass view.
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::View::Rendering::LayoutRegistry
      # @see Lotus::View::Rendering#registry
      #
      # @example
      #   require 'lotus/view'
      #
      #   module Articles
      #     class Index
      #       include Lotus::View
      #     end
      #
      #     class Show
      #       include Lotus::View
      #     end
      #
      #     class JsonShow < Show
      #       format :json
      #     end
      #   end
      #
      #   # We have the following templates:
      #   #
      #   #  * articles/index.html.erb
      #   #  * articles/index.atom.erb
      #   #  * articles/show.html.erb
      #   #  * articles/show.json.erb
      #
      #   # One registry per superclass view
      #   Articles::Index.send(:registry).object_id     # => 70135342862240
      #
      #   Articles::Show.send(:registry).object_id      # => 70135342110540
      #   Articles::JsonShow.send(:registry).object_id  # => 70135342110540
      #
      #
      #
      #   # It holds the references for all the templates and the views
      #   Articles::Index.send(:registry).inspect
      #     # => { :atom => [Articles::Index, #<Lotus::View::Template ... @file="/path/to/templates/articles/index.atom.erb"],
      #     #      :html => [Articles::Index, #<Lotus::View::Template ... @file="/path/to/templates/articles/index.html.erb"] }
      #
      #   Articles::Show.send(:registry).inspect
      #     # => { :html => [Articles::Index,     #<Lotus::View::Template ... @file="/path/to/templates/articles/show.html.erb"],
      #     #      :json => [Articles::JsonIndex, #<Lotus::View::Template ... @file="/path/to/templates/articles/show.json.erb"] }
      class Registry < LayoutRegistry
        # Returns the view for the given context.
        #
        # @param context [Hash] the rendering context
        # @option context [Symbol] :format the requested format
        # @param locals [Hash] the set of available objects
        #
        # @return [Lotus::View, Lotus::View::Rendering::NullView] the view
        #   associated with the given context or a `NullView` if
        #     it can't be found.
        #
        # @api private
        # @since 0.1.0
        #
        # @see Lotus::View::Rendering#render
        def resolve(context, locals)
          view, template = fetch(context[:format], NullView)
          view.new(template, locals.merge(context))
        end

        protected
        def prepare!
          templates.each do |template|
            merge! template.format => [ _view_for(template), template ]
          end
        end

        def _view_for(template)
          ViewFinder.new(@view).find(template)
        end
      end
    end
  end
end
