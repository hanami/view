# frozen_string_literal: true

require "dry/core/cache"

module Hanami
  class View
    # Shared cache for views.
    #
    # @api public
    # @since 2.1.0
    class Cache
      extend Dry::Core::Cache

      # Clears the view cache.
      #
      # @api public
      # @since 2.1.0
      def self.clear
        cache.clear
      end
    end
  end
end
