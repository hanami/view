# frozen_string_literal: true

require "hanami/view/helpers/html_helper"

RSpec.describe Hanami::View::Helpers::HTMLHelper do
  subject(:obj) {
    Class.new {
      include Hanami::View::Helpers::HTMLHelper
    }.new
  }

  def h(&block)
    obj.instance_eval(&block).to_s
  end

  it "includes private helpers only" do
    expect { obj.html }.to raise_error(NoMethodError)
  end

  it "returns a safe string" do
    expect(h { html }).to be_html_safe
  end

  it "returns an empty tag" do
    expect(h { html.div {} }).to eq "<div></div>"
  end

  it "returns a tag with string content" do
    expect(h { html.div("hello world") }).to eq "<div>hello world</div>"
  end

  it "returns a tag with block content as string" do
    expect(h { html.div { text("hola") } }).to eq "<div>hola</div>"
  end

  it "returns a tag with block content as tag helper" do
    expect(h { html.div(html.p("inner")) }).to eq "<div><p>inner</p></div>"
  end

  it "returns a tag with block content with nested calls" do
    expect(h {
      html.div do
        span "hello"
      end
    }).to eq "<div><span>hello</span></div>"
  end

  it "returns a tag with block content with multiple nested calls" do
    expect(h {
      html.form(action: "/users", method: "POST") do
        div do
          label "First name", for: "user-first-name"
          input type: "text", id: "user-first-name", name: "user[first_name]", value: "L"
        end

        input type: "submit", value: "Save changes"
      end
    }).to eq %(<form action="/users" method="POST"><div><label for="user-first-name">First name</label><input type="text" id="user-first-name" name="user[first_name]" value="L"></div><input type="submit" value="Save changes"></form>)
   end

  it "returns a concatenation of multiple divs" do
    expect(h {
      html.div("Hello") + html.div("Hanami")
    }).to eq "<div>Hello</div><div>Hanami</div>"
  end

  it "returns a concatenation of multiple fragments" do
    expect(h {
      hello  = html { div "Hello" }
      hanami = html { div "Hanami" }

      hello + hanami
    }).to eq "<div>Hello</div><div>Hanami</div>"
  end

  it "returns a concatenation of fragment and div" do
    expect(h {
      html { div "Hello" } + html.div("Hanami")
    }).to eq "<div>Hello</div><div>Hanami</div>"
  end

  it "returns a fragment with block content as string" do
    expect(h {
      html do
        div "Hello"
        div "Hanami"
      end
    }).to eq "<div>Hello</div><div>Hanami</div>"
  end

  it "returns a tag with attribute" do
    expect(h {
      html.div(id: "container") {}
    }).to eq %(<div id="container"></div>)
  end

  it "returns a tag with data attribute" do
    expect(h {
      html.div("data-where": "up") {}
    }).to eq %(<div data-where="up"></div>)
  end

  it "returns a tag with attributes" do
    expect(h {
      html.div(id: "content", class: "filled") {}
    }).to eq %(<div id="content" class="filled"></div>)
  end

  it "returns a tag with string content and attributes" do
    expect(h {
      html.div("ciao", id: "greeting", class: "blink")
    }).to eq %(<div id="greeting" class="blink">ciao</div>)
  end

  it "returns a tag with block content as string and attributes" do
    expect(h {
      html.div(id: "sidebar", class: "blue") { text "bonjour" }
    }).to eq %(<div id="sidebar" class="blue">bonjour</div>)
  end

  it "returns a custom tag" do
    expect(h {
      html.custom("Foo", id: "next")
    }).to eq %(<custom id="next">Foo</custom>)
  end

  it "returns a custom empty tag" do
    expect(h {
      html.empty_tag(:xr, id: "next")
    }).to eq %(<xr id="next">)
  end

  it "autoescapes string contents" do
    expect(h {
      html.div("<script>alert('xss')</script>")
    }).to eq %(<div>&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;</div>)
  end

  it "autoescapes block contents" do
    expect(h {
      html.div { text "<script>alert('xss')</script>" }
    }).to eq %(<div>&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;</div>)
  end

  it "autoescapes nested helpers contents" do
    expect(h {
      html.div(html.p("<script>alert('xss')</script>"))
    }).to eq %(<div><p>&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;</p></div>)
  end

  it "autoescapes nested blocks" do
    expect(h {
      html.div do
        p "<script>alert('xss')</script>"
      end
    }).to eq %(<div><p>&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;</p></div>)
  end

  # # describe "with link_to helper" do
  # #   let(:view) { HtmlAndLinkTo.new }

  # #   it "returns two links in div" do
  # #     expect(view.two_links_to_in_div.to_s).to eq(%(<div><a href=\"/comments\">Comments</a><a href=\"/posts\">Posts</a></div>))
  # #   end

  # #   it "returns span and link in div" do
  # #     expect(view.span_and_link_to_in_div.to_s).to eq(%(<div><span>hello</span><a href=\"/comments\">Comments</a></div>))
  # #   end
  # # end
end
