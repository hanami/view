# frozen_string_literal: true

# Based on ActionView::Helpers::TagHelper, also released under the MIT licence.
#
# Copyright (c) David Heinemeier Hansson

require_relative "escape_helper"

module Hanami
  class View
    module Helpers
      module TagHelper
        require_relative "tag_helper/tag_builder"

        module_function

        # Returns a tag builder for building HTML tag strings.
        #
        # @example General usage
        #   tag.div # => <div></div>
        #   tag.img # => <img>
        #
        #   tag.div("hello")        # => <div>hello</div>
        #   tag.div { "hello" }     # => <div>hello</div>
        #   tag.div(tag.p("hello")) # => <div><p>hello</p></div>
        #
        #   tag.div(class: ["a", "b"])              # => <div class="a b"></div>
        #   tag.div(class: {"a": true, "b": false}) # => <div class="a"></div>
        #
        #   tag.div(id: "el", data: {x: "y"}) # => <div id="el" data-x="y"></div>
        #   tag.div(id: "el", aria: {x: "y"}) # => <div id="el" aria-x="y"></div>
        #
        #   tag.custom_tag("hello") # => <custom-tag>hello</custom-tag>
        #
        # @example Escaping
        #   tag.p("<script>alert()</script>")         # => <p>&lt;script&gt;alert()&lt;/script&gt;</p>
        #   tag.p(class: "<script>alert()</script>")  # => <p class="&lt;script&gt;alert()&lt;/script&gt;"></p>
        #   tag.p("<em>safe content</em>".html_safe)  # => <p><em>safe content</em></p>
        #
        # @example Within templates
        #   <%= tag.div(id: "el") do %>
        #     <p>Template content can be mixed in.</p>
        #     <%= tag.p("Also nested tag builders.") %>
        #   <% end %>
        #
        # @api public
        # @since 2.0.0
        def tag
          tag_builder
        end

                # Generates an anchor tag for the given arguments.
        #
        # Contents are automatically escaped.
        #
        # @overload link_to(content, url, **attributes)
        #   Use string as content
        #   @param content [String] content used in the a tag
        #   @param url [String] url used in href attribute
        #   @param attributes [Hash] HTML attributes to pass to the a tag
        #
        # @overload link_to(url, **attributes, &block)
        #   Use block as content
        #   @param url [String] url used in href attribute
        #   @param attributes [Hash] HTML attributes to pass to the a tag
        #   @param block [Proc] A block that describes the contents of the a tag
        #
        # @return [String] HTML markup for the link
        #
        # @raise [ArgumentError] if the signature isn"t respected
        #
        # @since 2.0.0
        #
        # @see Hanami::Helpers::HtmlHelper#html
        #
        # @example Both content and URL are strings
        #   <%= link_to("Home", "/") %>
        #     # => <a href="/">Home</a>
        #
        # @example Content string with route helper
        #   <%= link_to("Home", routes.path(:home)) %>
        #     # => <a href="/">Home</a>
        #
        # @example HTML attributes
        #   <%= link_to("Home", routes.path(:home), class: "button") %>
        #     # => <a href="/" class="button">Home</a>
        #
        # @example Automatic content escape (XSS protection)
        #   <%= link_to(%(<script>alert("xss")</script>), "/") %>
        #     # => <a href="/">&lt;script&gt;alert(&apos;xss&apos;)&lt;&#x2F;script&gt;</a>
        #
        # @example Automatic content block escape (XSS protection)
        #   <%=
        #     link_to("/") do
        #       %(<script>alert("xss")</script>)
        #     end
        #   %>
        #     # => <a href="/">\n&lt;script&gt;alert(&apos;xss&apos;)&lt;&#x2F;script&gt;\n</a>
        #
        # @example Content as block with string URL
        #   <%=
        #     link_to("/") do
        #       "Home"
        #     end
        #   %>
        #     # => <a href="/">Home</a>
        #
        # @example Content as block
        #   <%=
        #     link_to(routes.path(:home)) do
        #       "Home"
        #     end
        #   %>
        #     # => <a href="/">Home</a>
        #
        # @example Content as block with HTML attributes
        #   <%=
        #     link_to(routes.path(:home), id: "home-link") do
        #       "Home"
        #     end
        #   %>
        #     # => <a href="/" id: "home-link">Home</a>
        #
        # @example Content as HTML builder block
        #   <%=
        #     link_to(routes.path(:home)) do
        #       strong "Home"
        #     end
        #   %>
        #     # => <a href="/"><strong>Home</strong></a>
        #
        # @example Provides both content as first argument and block
        #   <%=
        #     link_to("Home", routes.path(:home)) do
        #       strong "Home"
        #     end
        #   %>
        #     # => ArgumentError
        #
        # @example Without any argument
        #   <%= link_to %>
        #     # => ArgumentError
        #
        # @example Without any argument and empty block
        #   <%=
        #     link_to do
        #     end
        #   %>
        #     # => ArgumentError
        #
        # @example With only content
        #   <%= link_to "Home" %>
        #     # => ArgumentError
        def link_to(content, url = nil, **attributes, &block)
          if block
            raise ArgumentError if url && content

            url = content
            content = nil
          end

          attributes[:href] = url or raise ArgumentError

          tag.a(content, **attributes, &block)
        end

        # Returns a string of space-separated tokens from a range of given arguments.
        #
        # This is intended for building an HTML tag attribute value, such as a list of class names.
        #
        # @example
        #   token_list("foo", "bar")
        #   # => "foo bar"
        #
        #   token_list("foo", "foo bar")
        #   # => "foo bar"
        #
        #   token_list({ foo: true, bar: false })
        #   # => "foo"
        #
        #   token_list(nil, false, 123, "", "foo", { bar: true })
        #   # => "123 foo bar"
        #
        # @api public
        # @since 2.0.0
        def token_list(*args)
          tokens = build_tag_values(*args).flat_map { |value|
            safe = value.html_safe?
            value.split(/\s+/).map { |s| safe ? s.html_safe : s }
          }

          EscapeHelper.escape_join(tokens, " ")
        end

        # @see #token_list
        #
        # @api public
        # @since 2.0.0
        def class_names(...)
          token_list(...)
        end

        # @api private
        # @since 2.0.0
        def build_tag_values(*args)
          tag_values = []

          args.each do |tag_value|
            case tag_value
            when Hash
              tag_value.each do |key, val|
                tag_values << key.to_s if val && !key.to_s.empty?
              end
            when Array
              tag_values.concat build_tag_values(*tag_value)
            else
              tag_values << tag_value.to_s unless tag_value.to_s.empty?
            end
          end

          tag_values
        end

        # @api private
        # @since 2.0.0
        def tag_builder
          @tag_builder ||= begin
            inflector = respond_to?(:_context) ? _context.inflector : Dry::Inflector.new
            TagBuilder.new(inflector: inflector)
          end
        end
      end
    end
  end
end
