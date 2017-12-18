module Hanami
  module View
    module Rendering
      # Null Object pattern for layout template
      #
      # It's used when a layout doesn't have an associated template.
      #
      # A common scenario is for non-html requests.
      # Usually we have a template for the application layout
      # (eg `templates/application.html.erb`), but we don't use to have the
      # template for JSON requests (eg `templates/application.json.erb`).
      # Because most of the times, we only return the output of the view.
      #
      # @api private
      # @since 0.1.0
      #
      # @example
      #   require 'hanami/view'
      #
      #   # We have an ApplicationLayout (views/application_layout.rb):
      #   class ApplicationLayout
      #     include Hanami::Layout
      #   end
      #
      #   # Our layout has a template for HTML requests, located at:
      #   # templates/application.html.erb
      #
      #   # We set it as global layout
      #   Hanami::View.layout = :application
      #
      #   # We have two views for HTML and JSON articles.
      #   # They have a template each:
      #   #
      #   #   * templates/articles/show.html.erb
      #   #   * templates/articles/show.json.erb
      #   module Articles
      #     class Show
      #       include Hanami::View
      #       format :html
      #     end
      #
      #     class JsonShow < Show
      #       format :json
      #     end
      #   end
      #
      #   # We initialize the framework
      #   Hanami::View.load!
      #
      #
      #
      #   # When we ask for a HTML rendering, it will use `Articles::Show` and
      #   # ApplicationLayout. The output will be a composition of:
      #   #
      #   #   * templates/articles/show.html.erb
      #   #   * templates/application.html.erb
      #
      #   # When we ask for a JSON rendering, it will use `Articles::JsonShow`
      #   # and ApplicationLayout. Since, the layout doesn't have any associated
      #   # template for JSON, the output will be a composition of:
      #   #
      #   #   * templates/articles/show.json.erb
      class NullTemplate
        # Render the layout template
        #
        # @param scope [Hanami::View::Scope] the rendering scope
        # @param locals [Hash] a set of objects available during the rendering
        # @yield [Proc] yields the given block
        #
        # @return [String] the output of the rendering process
        #
        # @api private
        # @since 0.1.0
        #
        # @see Hanami::Layout#render
        # @see Hanami::View::Rendering#render
        def render(scope, locals = {})
          yield
        end
      end
    end
  end
end
