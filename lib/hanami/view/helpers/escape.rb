# frozen_string_literal: true

require "temple/utils"
require "temple/html/safe"
require "escape_utils"

module Hanami
  class View
    module Helpers
      module Escape
        def self.call(string)
          Temple::Utils.escape_html_safe(string)
        end

        def self.safe_string(string)
          Temple::HTML::SafeString.new(string.to_s)
        end

        def self.uri(string)
          ::EscapeUtils.escape_uri(string)
        end
      end
    end
  end
end
