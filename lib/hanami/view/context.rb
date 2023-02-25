# frozen_string_literal: true

require_relative "decorated_attributes"

module Hanami
  class View
    # Provides a baseline environment across all the templates, parts and scopes
    # in a given rendering.
    #
    # @abstract Subclass this and add your own methods (along with a custom
    #   `#initialize` if you wish to inject dependencies)
    #
    # @api public
    class Context
      include DecoratedAttributes

      # @api private
      attr_reader :_rendering

      # @api private
      def self.new(rendering: RenderingMissing.new, **args)
        allocate.tap do |obj|
          obj.instance_variable_set(:@_rendering, rendering)
          obj.send(:initialize, **args)
        end
      end

      # Returns a new instance of Context
      #
      # @api public
      def initialize(**)
      end

      # @api private
      SKIP_COPY_IVARS = %i[@_rendering].freeze
      private_constant :SKIP_COPY_IVARS

      # @api private
      private def initialize_copy(source)
        ivars = source.instance_variables - SKIP_COPY_IVARS
        ivars.each do |ivar|
          instance_variable_set(ivar, source.instance_variable_get(ivar).dup)
        end
      end

      # @api private
      def dup_for_rendering(rendering)
        dup.tap do |obj|
          obj.instance_variable_set(:@_rendering, rendering)
        end
      end
    end
  end
end
