# frozen_string_literal: true

module Hanami
  class View
    module HTML
      require_relative "html/safe_string"
      require_relative "html/helpers"

      # @api private
      # @since 2.0.0
      module StringExtensions
        # Returns the string as a {Hanami::View::HTML::SafeString}, ensuring the string is not
        # automatically escaped when used in HTML view templates.
        #
        # @return [Hanami::View::HTML::SafeString]
        #
        # @api public
        # @since 2.0.0
        def html_safe
          SafeString.new(self)
        end
      end
    end
  end
end

class String
  # Prepend our `#html_safe` method so that it takes precedence over Active Support's. When both
  # methods are loaded, the more likely scenario is that the user will want Hanami's, since in the
  # context of a Hanami app, Active Support is more likely to be loaded incidentally, as a
  # transitive dependency of another gem.
  #
  # Having our `#html_safe` available via this module also means that a user can also choose to
  # _undefine_ this method within the module if they'd rather use Active Support's.
  prepend Hanami::View::HTML::StringExtensions
end

class Object
  # @return [false]
  #
  # @api public
  # @since 2.0.0
  def html_safe?
    false
  end
end

class Numeric
  # @return [true]
  #
  # @api public
  # @since 2.0.0
  def html_safe?
    true
  end
end


