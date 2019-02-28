# frozen_string_literal: true

require "dry/view"
require "hanami/utils/string"

# Hanami
#
# @since 0.1.0
module Hanami
  require "hanami/view/version"

  # View
  #
  # @since 2.0.0
  class View < Dry::View
    MODULE_SEPARATOR_TRANSFORMER = [:gsub, "::", "."].freeze

    attr_reader :name

    def initialize(**)
      super()
      @name = Utils::String.transform(self.class.name, MODULE_SEPARATOR_TRANSFORMER, :underscore).freeze unless self.class.name.nil?
      freeze
    end
  end
end
