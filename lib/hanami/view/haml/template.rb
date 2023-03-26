# frozen_string_literal: true

require "haml"

module Hanami
  class View
    # @api private
    module HamlAdapter
      # Haml template renderer for Hanami::View.
      #
      # This differs from the standard Haml::Template by automatically escaping HTML depending on
      # the given string's `#html_safe?` status.
      #
      # @see Hanami::View::Tilt
      # @api private
      Template = Temple::Templates::Tilt(::Haml::Engine, use_html_safe: true)
    end
  end
end
