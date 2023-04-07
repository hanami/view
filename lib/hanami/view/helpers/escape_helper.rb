# frozen_string_literal: true

require "hanami/helpers/escape"
require "hanami/utils/escape"

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
        private

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
          Helpers::Escape.(input)
        end

        # @since 0.1.0
        alias_method :h, :escape_html

        # Escape the given HTML tag attribute.
        #
        # This MUST be used for escaping HTML tag attributes.
        #
        # This should be used only for untrusted contents: user input.
        #
        # This can also be used to escape tag contents, but it's slower.
        # For this purpose use <tt>Hanami::Helpers::EscapeHelper#escape_html</tt>.
        #
        # @param input [String] the input
        #
        # @return [String] the escaped string
        #
        # @since 0.1.0
        #
        # @see Hanami::Helpers::EscapeHelper#escape_html
        #
        # @example Basic usage
        #   require 'hanami/helpers/escape_helper'
        #
        #   class MyView
        #     include Hanami::Helpers::EscapeHelper
        #
        #     def good_attribute
        #       attribute = "small"
        #
        #       %(<span class="#{ ha(attribute) }">hello</span>
        #     end
        #
        #     def evil_attribute
        #       attribute = %(" onclick="javascript:alert('xss')" id=")
        #
        #       %(<span class="#{ ha(attribute) }">hello</span>
        #     end
        #   end
        #
        #   view = MyView.new
        #
        #   view.good_attribute
        #     # => %(<span class="small">hello</span>)
        #
        #   view.evil_attribute
        #     # => %(<span class="&quot;&#x20;onclick&#x3d;&quot;javascript&#x3a;alert&#x28;&#x27;xss&#x27;&#x29;&quot;&#x20;id&#x3d;&quot;">hello</span>
        #
        # @example With HTML builder
        #   #
        #   # ATTRIBUTES AREN'T AUTOMATICALLY ESCAPED
        #   #
        #   require 'hanami/helpers'
        #
        #   class MyView
        #     include Hanami::Helpers
        #
        #     def evil_attribute
        #       user_input_attribute = %(" onclick="javascript:alert('xss')" id=")
        #
        #       html.span id: 'greet', class: ha(user_input_attribute) do
        #         "hello"
        #       end
        #     end
        #   end
        #
        #   view = MyView.new
        #   view.evil_attribute
        #     # => %(<span class="&quot;&#x20;onclick&#x3d;&quot;javascript&#x3a;alert&#x28;&#x27;xss&#x27;&#x29;&quot;&#x20;id&#x3d;&quot;">hello</span>
        def escape_html_attribute(input)
          Utils::Escape.html_attribute(input)
        end

        # @since 0.1.0
        alias_method :ha, :escape_html_attribute

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
        def escape_url(input, schemes = Utils::Escape::DEFAULT_URL_SCHEMES)
          Utils::Escape.url(input, schemes)
        end

        # @since 0.1.0
        alias_method :hu, :escape_url

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
          Helpers::Escape.safe_string(input)
        end
      end
    end
  end
end
