# frozen_string_literal: true

require "dry/types"

module Hanami
  module Helpers
    # @since 2.0.0
    # @api private
    module Types
      include Dry.Types()
    end
  end
end
