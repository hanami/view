# frozen_string_literal: true

module Hanami
  class View
    module Helpers
      # HTML builder
      #
      # By including <tt>Hanami::Helpers::HtmlHelper</tt> it will inject one private method: <tt>html</tt>.
      # This is a HTML5 markup builder.
      #
      # Features:
      #
      #   * Support for complex markup without the need of concatenation
      #   * Auto closing HTML5 tags
      #   * Custom tags
      #   * Content tag auto escape (XSS protection)
      #   * Support for view local variables
      #
      # Usage:
      #
      #   * It knows how to close tags according to HTML5 spec (1)
      #   * It accepts content as first argument (2)
      #   * It accepts another builder as first argument (3)
      #   * It accepts content as block which returns a string (4)
      #   * It accepts content as a block with nested markup builders (5)
      #   * It builds attributes from given hash (6)
      #   * It combines attributes and block (7)
      #
      # @since 0.1.0
      #
      # @see Hanami::Helpers::HtmlHelper#html
      #
      # @example Usage
      #   # 1
      #   html.div # => <div></div>
      #   html.img # => <img>
      #
      #   # 2
      #   html.div("hello") # => <div>hello</div>
      #
      #   # 3
      #   html.div(html.p("hello")) # => <div><p>hello</p></div>
      #
      #   # 4
      #   html.div { text "hello" }
      #   # =>
      #   #<div>
      #   #  hello
      #   #</div>
      #
      #   # 5
      #   html.div do
      #     p "hello"
      #   end
      #   # =>
      #   #<div>
      #   #  <p>hello</p>
      #   #</div>
      #
      #   # 6
      #   html.div("hello", id: "el", "data-x": "y") # => <div id="el" data-x="y">hello</div>
      #
      #   # 7
      #   html.div(id: "yay") { text("hello") }
      #   # =>
      #   #<div id="yay">
      #   #  hello
      #   #</div>
      #
      #   # 8
      #   html do
      #     li "Hello"
      #     li "Hanami"
      #   end
      #   # =>
      #   #<li>Hello</li>
      #   #<li>Hanami</li>
      #
      #
      #
      # @example Complex markup
      #   #
      #   # NOTICE THE LACK OF CONCATENATION BETWEEN div AND input BLOCKS <3
      #   #
      #
      #   html.form(action: "/users", method: "POST") do
      #     div do
      #       label "First name", for: "user-first-name"
      #       input type: "text", id: "user-first-name", name: "user[first_name]", value: "L"
      #     end
      #
      #     input type: "submit", value: "Save changes"
      #   end
      #   # =>
      #   #<form action="/users" method="POST" accept-charset="utf-8">
      #   #  <div>
      #   #    <label for="user-first-name">First name</label>
      #   #    <input type="text" id="user-first-name" name="user[first_name]" value="L">
      #   #  </div>
      #   #  <input type="submit" value="Save changes">
      #   #</form>
      #
      #
      #
      # @example Custom tags
      #   html.tag(:custom, "Foo", id: "next") # => <custom id="next">Foo</custom>
      #   html.empty_tag(:xr, id: "next")      # => <xr id="next">
      #
      #
      #
      # @example Auto escape
      #  html.div("hello")         # => <div>hello</hello>
      #  html.div { "hello" }      # => <div>hello</hello>
      #  html.div(html.p("hello")) # => <div><p>hello</p></hello>
      #  html.div do
      #    p "hello"
      #  end # => <div><p>hello</p></hello>
      #
      #
      #
      #  html.div("<script>alert("xss")</script>")
      #    # =>  "<div>&lt;script&gt;alert(&apos;xss&apos;)&lt;&#x2F;script&gt;</div>"
      #
      #  html.div { "<script>alert("xss")</script>" }
      #    # =>  "<div>&lt;script&gt;alert(&apos;xss&apos;)&lt;&#x2F;script&gt;</div>"
      #
      #  html.div(html.p("<script>alert("xss")</script>"))
      #    # => "<div><p>&lt;script&gt;alert(&apos;xss&apos;)&lt;&#x2F;script&gt;</p></div>"
      #
      #  html.div do
      #    p "<script>alert("xss")</script>"
      #  end
      #    # => "<div><p>&lt;script&gt;alert(&apos;xss&apos;)&lt;&#x2F;script&gt;</p></div>"
      #
      #
      # @example Basic usage
      #   #
      #   # THE VIEW CAN BE A SIMPLE RUBY OBJECT
      #   #
      #
      #   require "hanami/helpers"
      #
      #   class MyView
      #     include Hanami::Helpers::HtmlHelper
      #
      #     # Generates
      #     # <aside id="sidebar">
      #     #    <div>hello</hello>
      #     #  </aside>
      #     def sidebar
      #       html.aside(id: "sidebar") do
      #         div "hello"
      #       end
      #     end
      #   end
      #
      #
      # @example View context
      #   #
      #   # LOCAL VARIABLES FROM VIEWS ARE AVAILABLE INSIDE THE NESTED BLOCKS OF HTML BUILDER
      #   #
      #
      #   require "hanami/view"
      #   require "hanami/helpers"
      #
      #   Book = Struct.new(:title)
      #
      #   module Admin
      #     module View
      #       class Context < MyApp::View::Context
      #         def title_widget
      #           html.div do
      #             h1 book.title
      #           end
      #         end
      #       end
      #     end
      #   end
      #
      #   book     = Book.new("The Work of Art in the Age of Mechanical Reproduction")
      #   rendered = Books::Show.new.(book: book)
      #
      #   rendered
      #     # => <div>
      #     #      <h1>The Work of Art in the Age of Mechanical Reproduction</h1>
      #     #    </div>
      module HTMLHelper
        require_relative "html_helper/html_builder"

        private

        # Instantiate an HTML builder
        #
        # @param blk [Proc,Hanami::Helpers::HtmlHelper::HtmlBuilder,NilClass] the optional content block
        #
        # @return [Hanami::Helpers::HtmlHelper::HtmlBuilder] the HTML builder
        #
        # @since 0.1.0
        #
        # @see Hanami::Helpers::HtmlHelper
        # @see Hanami::Helpers::HtmlHelper::HtmlBuilder
        def html(&blk)
          HTMLBuilder.new(&blk)
        end
      end
    end
  end
end
