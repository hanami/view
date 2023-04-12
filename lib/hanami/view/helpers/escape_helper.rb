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

        # Returns an escaped, HTML safe string from a given array.
        #
        # Behaves similarly to `Array#join`. In addition, given array is flattened, and all items,
        # including the supplied separator, are HTML escaped unless they are already HTML safe. The
        # returned string is also marked as HTML safe.
        #
        # @example
        #   safe_join([raw("<p>foo</p>"), "<p>bar</p>"], "<br />")
        #   # => "<p>foo</p>&lt;br /&gt;&lt;p&gt;bar&lt;/p&gt;"
        #
        #   safe_join([raw("<p>foo</p>"), raw("<p>bar</p>")], raw("<br />"))
        #   # => "<p>foo</p><br /><p>bar</p>"
        #
        # @api public
        # @since 2.0.0
        def escape_join(array, sep = $,)
          sep = escape_html(sep)

          array.flatten.map { |i| escape_html(i) }.join(sep).html_safe
        end

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

        # Returns an escaped name from the given string, intended for use as an XML tag or attribute
        # name.
        #
        # Replaces non-safe characters with an underscore.
        #
        # Follows the requirements of the [XML specification](https://www.w3.org/TR/REC-xml/#NT-Name).
        #
        # @example
        #   escape_xml_name("1 < 2 & 3")
        #   # => "1___2___3"
        #
        # @api public
        # @since 2.0.0
        def escape_xml_name(name)
          name = name.to_s
          return "" if name.empty?
          return name if name.match?(SAFE_XML_TAG_NAME_REGEXP)

          starting_char = name[0]
          starting_char.gsub!(INVALID_TAG_NAME_START_REGEXP, TAG_NAME_REPLACEMENT_CHAR)

          return starting_char if name.size == 1

          following_chars = name[1..-1]
          following_chars.gsub!(INVALID_TAG_NAME_FOLLOWING_REGEXP, TAG_NAME_REPLACEMENT_CHAR)

          starting_char << following_chars
        end

        # Following XML requirements: https://www.w3.org/TR/REC-xml/#NT-Name
        # @api private
        # @since 2.0.0
        TAG_NAME_START_CODEPOINTS = \
          "@:A-Z_a-z\u{C0}-\u{D6}\u{D8}-\u{F6}\u{F8}-\u{2FF}\u{370}-\u{37D}\u{37F}-\u{1FFF}" \
          "\u{200C}-\u{200D}\u{2070}-\u{218F}\u{2C00}-\u{2FEF}\u{3001}-\u{D7FF}\u{F900}-\u{FDCF}" \
          "\u{FDF0}-\u{FFFD}\u{10000}-\u{EFFFF}"
        private_constant :TAG_NAME_START_CODEPOINTS

        # @api private
        # @since 2.0.0
        INVALID_TAG_NAME_START_REGEXP = /[^#{TAG_NAME_START_CODEPOINTS}]/
        private_constant :INVALID_TAG_NAME_START_REGEXP

        # @api private
        # @since 2.0.0
        TAG_NAME_FOLLOWING_CODEPOINTS = "#{TAG_NAME_START_CODEPOINTS}\\-.0-9\u{B7}\u{0300}-\u{036F}\u{203F}-\u{2040}"
        private_constant :TAG_NAME_FOLLOWING_CODEPOINTS

        # @api private
        # @since 2.0.0
        INVALID_TAG_NAME_FOLLOWING_REGEXP = /[^#{TAG_NAME_FOLLOWING_CODEPOINTS}]/
        private_constant :INVALID_TAG_NAME_FOLLOWING_REGEXP

        # @api private
        # @since 2.0.0
        SAFE_XML_TAG_NAME_REGEXP = /\A[#{TAG_NAME_START_CODEPOINTS}][#{TAG_NAME_FOLLOWING_CODEPOINTS}]*\z/
        private_constant :INVALID_TAG_NAME_FOLLOWING_REGEXP

        # @api private
        # @since 2.0.0
        TAG_NAME_REPLACEMENT_CHAR = "_"
        private_constant :TAG_NAME_REPLACEMENT_CHAR

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
