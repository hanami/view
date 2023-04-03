# frozen_string_literal: true

require "temple"

module Hanami
  class View
    module HTML
      class << self
        def escape_html(string)
          Temple::Utils.escape_html_safe(string)
        end

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

      module Helpers
        def escape_html(...)
          HTML.escape_html(...)
        end

        alias_method :h, :escape_html

        def escape_url(...)
          HTML.escape_url(...)
        end

        def raw(string)
          string.to_s.html_safe
        end
      end
    end
  end
end
