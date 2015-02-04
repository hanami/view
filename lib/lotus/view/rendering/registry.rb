require 'lotus/view/rendering/layout_registry'
require 'lotus/view/rendering/view_finder'

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
      #
      #     class XmlShow < Show
      #       format :xml
      #
      #       def render
      #         ArticleSerializer.new(article).to_xml
      #       end
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
      #   Articles::XmlShow.send(:registry).object_id   # => 70135342110540
      #   Articles::JsonShow.send(:registry).object_id  # => 70135342110540
      #
      #
      #
      #   # It holds the references for all the templates and the views
      #   Articles::Index.send(:registry).inspect
      #     # => { :all  => [Articles::Index, nil],
      #     #      :atom => [Articles::Index, #<Lotus::View::Template ... @file="/path/to/templates/articles/index.atom.erb"],
      #     #      :html => [Articles::Index, #<Lotus::View::Template ... @file="/path/to/templates/articles/index.html.erb"] }
      #
      #   Articles::Show.send(:registry).inspect
      #     # => { :all  => [Articles::Show, nil],
      #     #      :html => [Articles::Show,     #<Lotus::View::Template ... @file="/path/to/templates/articles/show.html.erb"],
      #     #      :json => [Articles::JsonShow, #<Lotus::View::Template ... @file="/path/to/templates/articles/show.json.erb"],
      #     #      :xml  => [Articles::XmlShow, nil] }
      class Registry < LayoutRegistry
        # Default format for views without an explicit format.
        #
        # @api private
        # @since 0.1.0
        #
        # @see Lotus::View::Dsl#format
        DEFAULT_FORMAT = :all

        # Returns the view for the given context.
        #
        # @param context [Hash] the rendering context
        # @option context [Symbol] :format the requested format
        #
        # @return [Lotus::View] the view associated with the given context
        #
        # @raise [Lotus::View::MissingFormatError] if the given context doesn't
        #   have the :format key
        #
        # @api private
        # @since 0.1.0
        #
        # @see Lotus::View::Rendering#render
        def resolve(context)
          view, template = @registry.fetch(format(context)) { @registry[DEFAULT_FORMAT] }
          view.new(template, context)
        end

        private
        def prepare!
          prepare_views!
          prepare_templates!
        end

        def prepare_views!
          views.each do |view|
            @registry.merge! view.format || DEFAULT_FORMAT => [ view, template_for(view) ]
          end
        end

        def prepare_templates!
          templates.each do |template|
            @registry.merge! template.format => [ view_for(template), template ]
          end
        end

        def views
          @view.subclasses + [ @view ]
        end

        def view_for(template)
          ViewFinder.new(@view).find(template)
        end

        def template_for(view)
          templates.find {|template| template.format == view.format }
        end
      end
    end
  end
end
