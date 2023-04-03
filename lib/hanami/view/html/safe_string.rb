# frozen_string_literal: true

module Hanami
  class View
    module HTML
      # A string that has been marked as "HTML safe", ensuring that it is not automatically escaped
      # when used in HTML view templates.
      #
      # A SafeString is frozen when initialized to ensure it cannot be mutated after being marked as
      # safe, which could be an avenue for injection of unsafe content.
      #
      # @see String#html_safe
      #
      # @api public
      # @since 2.0.0
      class SafeString < String
        # @api public
        # @since 2.0.0
        def initialize(string)
          super(string)
          freeze
        end

        # @api private
        private def initialize_copy(other)
          super
          freeze
        end

        # @return [true]
        #
        # @api public
        # @since 2.0.0
        def html_safe?
          true
        end

        # @return [self]
        #
        # @api public
        # @since 2.0.0
        def html_safe
          self
        end

        # @return [self]
        #
        # @api public
        # @since 2.0.0
        def to_s
          self
        end
      end
    end
  end
end
