# frozen_string_literal: true

require "temple"

module Hanami
  class View
    module Helpers
      module EscapeHelper
        module_function

        def raw(string)
          string.to_s.html_safe
        end

        def escape_html(string)
          Temple::Utils.escape_html_safe(string)
        end

        alias_method :h, :escape_html

        PERMITTED_URL_SCHEMES = %w[http https mailto].freeze
        private_constant :PERMITTED_URL_SCHEMES

        def escape_url(url, permitted_schemes = PERMITTED_URL_SCHEMES)
          return url if url.html_safe?

          URI::DEFAULT_PARSER.extract(
            URI.decode_www_form_component(url.to_s),
            permitted_schemes
          ).first.to_s.html_safe
        end
      end
    end
  end
end
