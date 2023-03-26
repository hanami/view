# frozen_string_literal: true

require "slim"

module Hanami
  class View
    # @api private
    module SlimAdapter
      # Slim template renderer for Hanami::View.
      #
      # This differs from the standard Slim::Template by automatically escaping HTML based on a
      # given string's `#html_safe?`, regardless of when "hanami/view/html" is required.
      #
      # @see Hanami::View::Tilt
      # @api private
      Template = Temple::Templates::Tilt(::Slim::Engine, use_html_safe: true)
    end
  end
end
