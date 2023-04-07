# frozen_string_literal: true

module Hanami
  module Helpers
    # @api public
    # @since 2.0.0
    class Error < ::StandardError
    end

    # @api public
    # @since 2.0.0
    class CoercionError < Error
    end
  end
end
