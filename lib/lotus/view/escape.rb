require 'lotus/utils/escape'
require 'lotus/presenter'

module Lotus
  module View
    # Auto escape logic for views and presenters.
    #
    # @since 0.4.0
    module Escape
      module InstanceMethods
        private
        # Mark the given string as safe to render.
        #
        # !!! ATTENTION !!! This may open your application to XSS attacks.
        #
        # @param string [String] the input string
        #
        # @return [Lotus::Utils::Escape::SafeString] the string marked as safe
        #
        # @since 0.4.0
        # @api public
        #
        # @example View usage
        #   require 'lotus/view'
        #
        #   User = Struct.new(:name)
        #
        #   module Users
        #     class Show
        #       include Lotus::View
        #
        #       def user_name
        #         _raw user.name
        #       end
        #     end
        #   end
        #
        #   # ERB template
        #   # <div id="user_name"><%= user_name %></div>
        #
        #   user = User.new("<script>alert('xss')</script>")
        #   html = Users::Show.render(format: :html, user: user)
        #
        #   html # => <div id="user_name"><script>alert('xss')</script></div>
        #
        # @example Presenter usage
        #   require 'lotus/view'
        #
        #   User = Struct.new(:name)
        #
        #   class UserPresenter
        #     include Lotus::Presenter
        #
        #     def name
        #       _raw @object.name
        #     end
        #   end
        #
        #   user      = User.new("<script>alert('xss')</script>")
        #   presenter = UserPresenter.new(user)
        #
        #   presenter.name # => "<script>alert('xss')</script>"
        def _raw(string)
          ::Lotus::Utils::Escape::SafeString.new(string)
        end

        # Force the output escape for the given object
        #
        # @param object [Object] the input object
        #
        # @return [Lotus::View::Escape::Presenter] a presenter with output
        #   autoescape
        #
        # @since 0.4.0
        # @api public
        #
        # @see Lotus::View::Escape::Presenter
        #
        # @example View usage
        #   require 'lotus/view'
        #
        #   User = Struct.new(:first_name, :last_name)
        #
        #   module Users
        #     class Show
        #       include Lotus::View
        #
        #       def user
        #         _escape locals[:user]
        #       end
        #     end
        #   end
        #
        #   # ERB template:
        #   #
        #   # <div id="first_name">
        #   #   <%= user.first_name %>
        #   # </div>
        #   # <div id="last_name">
        #   #   <%= user.last_name %>
        #   # </div>
        #
        #   first_name = "<script>alert('first_name')</script>"
        #   last_name  = "<script>alert('last_name')</script>"
        #
        #   user = User.new(first_name, last_name)
        #   html = Users::Show.render(format: :html, user: user)
        #
        #   html
        #     # =>
        #     # <div id="first_name">
        #     #   &lt;script&gt;alert(&apos;first_name&apos;)&lt;&#x2F;script&gt;
        #     # </div>
        #     # <div id="last_name">
        #     #   &lt;script&gt;alert(&apos;last_name&apos;)&lt;&#x2F;script&gt;
        #     # </div>
        def _escape(object)
          ::Lotus::View::Escape::Presenter.new(object)
        end
      end

      # Auto escape presenter
      #
      # @since 0.4.0
      # @api private
      #
      # @see Lotus::View::Escape::InstanceMethods#_escape
      class Presenter
        include ::Lotus::Presenter
      end

      # Escape the given input if it's a string, otherwise return the oject as it is.
      #
      # @param input [Object] the input
      #
      # @return [Object,String] the escaped string or the given object
      #
      # @since 0.4.0
      # @api private
      def self.html(input)
        case input
        when String
          Utils::Escape.html(input)
        else
          input
        end
      end

      # Module extended override
      #
      # @since 0.4.0
      # @api private
      def self.extended(base)
        base.class_eval do
          include ::Lotus::Utils::ClassAttribute
          include ::Lotus::View::Escape::InstanceMethods

          class_attribute :autoescape_methods
          self.autoescape_methods = {}
        end
      end

      # Wraps concrete view methods with escape logic.
      #
      # @since 0.4.0
      # @api private
      def method_added(method_name)
        unless autoescape_methods[method_name]
          prepend Module.new {
            module_eval %{
              def #{ method_name }(*args, &blk); ::Lotus::View::Escape.html super; end
            }
          }

          autoescape_methods[method_name] = true
        end
      end
    end
  end
end
