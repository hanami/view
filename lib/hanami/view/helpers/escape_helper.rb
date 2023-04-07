# frozen_string_literal: true

require "escape_utils"
require "temple"
require "uri"

module Hanami
  class View
    module Helpers
      # Escape helpers
      #
      # You can include this module inside your view and
      # the view will have access all methods.
      #
      # By including <tt>Hanami::Helpers::EscapeHelper</tt> it will inject private
      # methods as markup escape utilities.
      #
      # @since 0.1.0
      module EscapeHelper
        module_function

        # Escape the given HTML tag content.
        #
        # This should be used only for untrusted contents: user input.
        #
        # This should be used only for tag contents.
        # To escape tag attributes please use <tt>Hanami::Helpers::EscapeHelper#escape_html_attribute</tt>.
        #
        # @param input [String] the input
        #
        # @return [String] the escaped string
        #
        # @since 0.1.0
        #
        # @see Hanami::Helpers::EscapeHelper#escape_html_attribute
        #
        # @example Basic usage
        #   require 'hanami/helpers/escape_helper'
        #
        #   class MyView
        #     include Hanami::Helpers::EscapeHelper
        #
        #     def good_content
        #       h "hello"
        #     end
        #
        #     def evil_content
        #       h "<script>alert('xss')</script>"
        #     end
        #   end
        #
        #   view = MyView.new
        #
        #   view.good_content
        #     # => "hello"
        #
        #   view.evil_content
        #     # => "&lt;script&gt;alert(&apos;xss&apos;)&lt;&#x2F;script&gt;"
        #
        # @example With HTML builder
        #   #
        #   # CONTENTS ARE AUTOMATICALLY ESCAPED
        #   #
        #   require 'hanami/helpers'
        #
        #   class MyView
        #     include Hanami::Helpers
        #
        #     def evil_content
        #       html.div do
        #         "<script>alert('xss')</script>"
        #       end
        #     end
        #   end
        #
        #   view = MyView.new
        #   view.evil_content
        #     # => "<div>\n&lt;script&gt;alert(&apos;xss&apos;)&lt;&#x2F;script&gt;</div>"
        def escape_html(input)
          Temple::Utils.escape_html_safe(input)
        end

        # @since 0.1.0
        alias_method :h, :escape_html

        # @api public
        # @since 2.0.0
        def escape_url(input)
          EscapeUtils.escape_uri(input)
        end

        # Escape an URL to be used in HTML attributes
        #
        # This allows only URLs with whitelisted schemes to pass the filter.
        # Everything else is stripped.
        #
        # Default schemes are:
        #
        #   * http
        #   * https
        #   * mailto
        #
        # If you want to allow a different set of schemes, you should pass it as
        # second argument.
        #
        # This should be used only for untrusted contents: user input.
        #
        # @param input [String] the input
        # @param schemes [Array<String>] an optional array of whitelisted schemes
        #
        # @return [String] the escaped string
        #
        # @since 0.1.0
        #
        # @see Hanami::Utils::Escape.url
        # @see Hanami::Utils::Escape::DEFAULT_URL_SCHEMES
        #
        # @example Basic usage
        #   require 'hanami/helpers/escape_helper'
        #
        #   class MyView
        #     include Hanami::Helpers::EscapeHelper
        #
        #     def good_url
        #       url = "http://hanamirb.org"
        #
        #       %(<a href="#{ hu(url) }">Hanami</a>
        #     end
        #
        #     def evil_url
        #       url = "javascript:alert('xss')"
        #
        #       %(<a href="#{ hu(url) }">Evil</a>
        #     end
        #   end
        #
        #   view = MyView.new
        #
        #   view.good_url
        #     # => %(<a href="http://hanamirb.org">Hanami</a>)
        #
        #   view.evil_url
        #     # => %(<a href="">Evil</a>)
        #
        # @example Custom schemes
        #   require 'hanami/helpers/escape_helper'
        #
        #   class MyView
        #     include Hanami::Helpers::EscapeHelper
        #
        #     def ftp_link
        #       schemes = ['ftp', 'ftps']
        #       url     = 'ftps://ftp.example.org'
        #
        #       %(<a href="#{ hu(url, schemes) }">FTP</a>
        #     end
        #   end
        #
        #   view = MyView.new
        #
        #   view.ftp_link
        #     # => %(<a href="ftps://ftp.example.org">FTP</a>)
        def sanitize_url(input, permitted_schemes = PERMITTED_URL_SCHEMES)
          return input if input.html_safe?

          URI::DEFAULT_PARSER.extract(
            URI.decode_www_form_component(input.to_s),
            permitted_schemes
          ).first.to_s.html_safe
        end

        PERMITTED_URL_SCHEMES = %w[http https mailto].freeze
        private_constant :PERMITTED_URL_SCHEMES

        # Bypass escape.
        #
        # Please notice that this can be really dangerous.
        # Use at your own peril.
        #
        # @param input [String] the input
        #
        # @return [Hanami::Utils::Escape::SafeString] the string marked as safe string
        #
        # @since 0.1.0
        #
        # @example
        #   require 'hanami/helpers/escape_helper'
        #
        #   class MyView
        #     include Hanami::Helpers::EscapeHelper
        #
        #     def good_content
        #       raw "<p>hello</p>"
        #     end
        #
        #     def evil_content
        #       raw "<script>alert('xss')</script>"
        #     end
        #   end
        #
        #   view = MyView.new
        #
        #   view.good_content
        #     # => "<p>hello</p>"
        #
        #   #
        #   # !!! WE HAVE OPENED OUR APPLICATION TO AN XSS ATTACK !!!
        #   #
        #   view.evil_content
        #     # => "<script>alert('xss')</script>"
        def raw(input)
          input.to_s.html_safe
        end
      end
    end
  end
end
