# frozen_string_literal: true

require "haml"

module Hanami
  class View
    module Haml
      # Haml template renderer for Hanami::View.
      #
      # This differs from the standard Haml::Template by automatically escaping HTML depending on
      # the given string's `#html_safe?` status.
      #
      # @see Hanami::View::Tilt
      Template = Temple::Templates::Tilt(::Haml::Engine, use_html_safe: true)
    end
  end
end
