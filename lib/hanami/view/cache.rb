# frozen_string_literal: true

require "dry/core/cache"

module Hanami
  class View
    # @api private
    class Cache
      extend Dry::Core::Cache

      def self.clear
        cache.clear
      end
    end
  end
end
