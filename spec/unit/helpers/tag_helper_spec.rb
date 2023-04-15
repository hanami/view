# frozen_string_literal: true

require "hanami/view/helpers/tag_helper"
require "hanami/view/erb/template"
require "hanami/view/slim/template"

RSpec.describe Hanami::View::Helpers::TagHelper do
  describe "inclusion" do
    subject(:obj) {
      Class.new {
        include Hanami::View::Helpers::TagHelper
      }.new
    }

    it "includes private helpers only" do
      expect { obj.tag }.to raise_error(NoMethodError)
    end
  end

  describe "#tag" do
    def tag(...)
      described_class.tag(...)
    end

    it "uses a singleton tag builder" do
      expect(tag).to be tag
    end

    it "builds opening and closing tags" do
      expect(tag.span).to eq %(<span></span>)
      expect(tag.span(class: "bookmark")).to eq %(<span class="bookmark"></span>)
    end

    it "builds void tags" do
      expect(tag.br).to eq %(<br>)
      expect(tag.br(class: "some_class")).to eq %(<br class="some_class">)
    end

    it "builds self-closing tags" do
      expect(tag.svg { tag.use("href" => "#cool-icon") }).to eq %(<svg><use href="#cool-icon" /></svg>)
      expect(tag.svg { tag.circle(cx: "5", cy: "5", r: "5") }).to eq %(<svg><circle cx="5" cy="5" r="5" /></svg>)
    end

    it "dasherizes tag names" do
      expect(tag.img_slider).to eq %(<img-slider></img-slider>)
    end

    it "responds to any tag" do
      expect(tag).to respond_to(:arbitrary_tag)
    end

    it "builds tags via called method objects" do
      expect(tag.method(:foo).call).to eq %(<foo></foo>)
    end

    it "returns a HTML safe string" do
      expect(tag.span).to be_html_safe
    end

    describe "tag content" do
      it "includes content given as an argument" do
        expect(tag.div("Content", class: "hello")).to eq %(<div class="hello">Content</div>)
      end

      it "includes content given via a block" do
        expect(tag.div(class: "hello") { "Content" }).to eq %(<div class="hello">Content</div>)
      end

      it "prefers the block content over the argument" do
        expect(tag.div("Arg content", class: "hello") { "Block content" }).to eq %(<div class="hello">Block content</div>)
      end

      it "includes content generated by nested tag builders" do
        expect(
          tag.div(id: "header") {
            tag.span {
              "Hello"
            }
          }
        ).to eq %(<div id="header"><span>Hello</span></div>)
      end

      it "forces content into void tags" do
        expect(tag.br("some content")).to eq %(<br>some content</br>)
      end

      it "forces content into self-closing tags" do
        expect(tag.svg { tag.circle { tag.desc "A circle" } }).to eq %(<svg><circle><desc>A circle</desc></circle></svg>)
      end
    end

    describe "tag attributes" do
      it "does not include nil values" do
        expect(tag.p(ignored: nil)).to eq "<p></p>"
      end

      it "includes false values" do
        expect(tag.p(value: false)).to eq %(<p value="false"></p>)
      end

      it "includes true values" do
        expect(tag.p(value: true)).to eq %(<p value="true"></p>)
      end

      it "includes empty string values" do
        expect(tag.p(included: "")).to eq %(<p included=""></p>)
      end

      it "includes symbol values" do
        expect(tag.p(included: :foo)).to eq %(<p included="foo"></p>)
      end

      it "includes numeric values" do
        expect(tag.p(value: 42)).to eq %(<p value="42"></p>)
      end

      it "includes both same-named string and symbol-keyed arguments" do
        expect(tag.p("class" => "here", :class => "there"))
          .to include(%(class="here"))
          .and include(%(class="there"))
      end

      it "builds attributes with dashed names" do
        expect(tag.p("data-foo" => "bar")).to eq %(<p data-foo="bar"></p>)
      end

      it "builds attributes with @-prefixed names" do
        expect(tag.p("@click" => "triggerNav()")).to eq %(<p @click="triggerNav()"></p>)
      end

      it "joins arrays of options and converts them to strings" do
        expect(tag.input(value: [123, "abc"])).to eq %(<input value="123 abc">)
        expect(tag.input(value: [123, "abc", [789]])).to eq %(<input value="123 abc 789">)

        obj = Class.new {
          def to_s; "hello"; end
        }.new
        expect(tag.input(value: obj)).to eq %(<input value="hello">)

        expect(tag.input(class: [])).to eq %(<input class="">)
      end

      it "builds class attributes from conditional hashes" do
        expect(tag.p(class: {song: true, play: false})).to eq %(<p class="song"></p>)
      end

      it "converts boolean attributes into attr=\"attr\" pairs" do
        html = tag.p(
          disabled: true,
          itemscope: true,
          multiple: true,
          readonly: true,
          allowfullscreen: true,
          seamless: true,
          typemustmatch: true,
          sortable: true,
          default: true,
          inert: true,
          truespeed: true,
          allowpaymentrequest: true,
          nomodule: true,
          playsinline: true,
        )

        expect(html).to eq <<~HTML.gsub(/\s+/, " ").strip
          <p
            disabled="disabled"
            itemscope="itemscope"
            multiple="multiple"
            readonly="readonly"
            allowfullscreen="allowfullscreen"
            seamless="seamless"
            typemustmatch="typemustmatch"
            sortable="sortable"
            default="default"
            inert="inert"
            truespeed="truespeed"
            allowpaymentrequest="allowpaymentrequest"
            nomodule="nomodule"
            playsinline="playsinline"></p>
        HTML
      end

      it "builds data attributes from a single `data:` hash, making minimal changes to the values" do
        ["data", :data].each do |data|
          expect(
            tag.a(
              data => {
                nil: nil,
                string: "hello",
                string_with_quotes: 'double"quote"party"',
                symbol: :foo,
                a_number: 1,
                a_float: 3.14,
                truthy: true,
                falsey: false,
                array: [1, 2, 3],
                empty_array: [],
                hash: {a: true, b: "truthy", falsey: false, nil: nil},
                empty_hash: {},
                tokens: ["a", {b: true, c: false}],
                empty_tokens: [{a: false}]
              }
            )
          ).to eq <<~HTML.gsub(/\s+/, " ").strip
            <a
              data-string="hello"
              data-string-with-quotes="double&quot;quote&quot;party&quot;"
              data-symbol="foo"
              data-a-number="1"
              data-a-float="3.14"
              data-truthy="true"
              data-falsey="false"
              data-array="[1,2,3]"
              data-empty-array="[]"
              data-hash="{&quot;a&quot;:true,&quot;b&quot;:&quot;truthy&quot;,&quot;falsey&quot;:false,&quot;nil&quot;:null}"
              data-empty-hash="{}"
              data-tokens="[&quot;a&quot;,{&quot;b&quot;:true,&quot;c&quot;:false}]"
              data-empty-tokens="[{&quot;a&quot;:false}]"></a>
          HTML
        end
      end

      it "builds aria attributes from a single `aria:` hash, simplifying the values" do
        ["aria", :aria].each do |aria|
          expect(
            tag.a(
              aria => {
                nil: nil,
                string: "hello",
                string_with_quotes: 'double"quote"party"',
                symbol: :foo,
                a_number: 1,
                a_float: 3.14,
                truthy: true,
                falsey: false,
                array: [1, 2, 3],
                empty_array: [],
                hash: {a: true, b: "truthy", falsey: false, nil: nil},
                empty_hash: {},
                tokens: ["a", {b: true, c: false}],
                empty_tokens: [{a: false}],
              }
            )
          ).to eq <<~HTML.gsub(/\s+/, " ").strip
          <a
            aria-string="hello"
            aria-string-with-quotes="double&quot;quote&quot;party&quot;"
            aria-symbol="foo"
            aria-a-number="1"
            aria-a-float="3.14"
            aria-truthy="true"
            aria-falsey="false"
            aria-array="1 2 3"
            aria-hash="a b"
            aria-tokens="a b"></a>
          HTML
        end
      end
    end

    describe "escaping" do
      let(:dangerous_chars) { "&<>\"' %*+,/;=^|" }
      let(:escaped_dangerous_chars) { ("_" * dangerous_chars.length).freeze }

      it "escapes content" do
        expect(tag.p("hello>")).to eq %(<p>hello&gt;</p>)
      end

      it "does not escape html safe content" do
        expect(tag.p("hello>".html_safe)).to eq %(<p>hello></p>)
      end

      it "escapes attribute values" do
        expect(tag.p(class: "hello>")).to eq %(<p class="hello&gt;"></p>)
        expect(tag.p(aria: {foo: "hello>"})).to eq %(<p aria-foo="hello&gt;"></p>)
        expect(tag.p(data: {foo: "hello>"})).to eq %(<p data-foo="hello&gt;"></p>)
      end

      it "escapes attribute values in arrays" do
        expect(tag.p(class: ["hello>"])).to eq %(<p class="hello&gt;"></p>)
      end

      it "escapes 'class' attribute values in conditional hashes" do
        expect(tag.p(class: {"hello>" => true, "song>" => false})).to eq %(<p class="hello&gt;"></p>)
      end

      it "does not escape html safe attribute values" do
        expect(tag.p(class: "hello>".html_safe)).to eq %(<p class="hello>"></p>)
        expect(tag.p(class: "&amp;".html_safe)).to eq %(<p class="&amp;"></p>)
      end

      it "does not escape html safe attribute values in arrays" do
        expect(tag.p(class: ["hello>".html_safe])).to eq %(<p class="hello>"></p>)
      end

      it "escapes double quote values" do
        expect(tag.p(foo: '"')).to eq %(<p foo="&quot;"></p>)
        expect(tag.p(aria: {foo: '"'})).to eq %(<p aria-foo="&quot;"></p>)
        expect(tag.p(data: {foo: '"'})).to eq %(<p data-foo="&quot;"></p>)
      end

      it "escapes double quote values even when html safe" do
        expect(tag.p(foo: '"'.html_safe)).to eq %(<p foo="&quot;"></p>)
        expect(tag.p(aria: {foo: '"'.html_safe})).to eq %(<p aria-foo="&quot;"></p>)
        expect(tag.p(data: {foo: '"'.html_safe})).to eq %(<p data-foo="&quot;"></p>)
      end

      it "escapes attribute values in arrays" do
        expect(tag.p(class: %w[hello> world])).to eq %(<p class="hello&gt; world"></p>)
      end

      it "escapes tag names" do
        expect(tag.public_send(dangerous_chars.to_sym)).to eq %(<#{escaped_dangerous_chars}></#{escaped_dangerous_chars}>)
      end

      it "escapes attribute names" do
        expect(tag.some_tag(dangerous_chars => "value")).to eq %(<some-tag #{escaped_dangerous_chars}="value"></some-tag>)
      end

      it "escapes data attribute names" do
        expect(tag.some_tag(data: {dangerous_chars => "value"})).to eq %(<some-tag data-#{escaped_dangerous_chars}="value"></some-tag>)
      end

      it "escapes aria attribute names" do
        expect(tag.some_tag(aria: {dangerous_chars => "value"})).to eq %(<some-tag aria-#{escaped_dangerous_chars}="value"></some-tag>)
      end
    end

    describe "in templates" do
      let(:scope) {
        Class.new { include Hanami::View::Helpers::TagHelper }.new
      }

      def erb(str)
        Hanami::View::ERB::Template.new { str }.render(scope)
      end

      it "includes content mixing nested tags as well as ordinary template content" do
        erb = erb(<<~ERB)
          <%= tag.div(id: "header") do %>
            <%= tag.span do %>
              Hello
              <% if false %>world<% end %>
            <% end %>
          <% end %>
        ERB

        expect(erb).to eq <<~HTML
          <div id="header">
            <span>
              Hello
            </span>
          </div>
        HTML
      end
    end
  end

  describe "#tag attributes" do
    def tag(...)
      described_class.tag(...)
    end

    it "builds an HTML attribute string" do
      expect(
        tag.attributes(
          value: nil,
          name: "name",
          "aria-hidden": false,
          aria: {label: "label"},
          data: {input_value: "data"},
          required: true
        )
      ).to eq %(name="name" aria-hidden="false" aria-label="label" data-input-value="data" required="required")
    end

    it "escapes attribute values" do
      expect(tag.attributes(xss: "<script>alert()</script>"))
        .to eq %(xss="&lt;script&gt;alert()&lt;/script&gt;")
    end

    it "excludes attributes with nil values" do
      expect(tag.attributes(excluded: nil)).to eq ""
    end

    it "returns an empty string when no attributes given" do
      expect(tag.attributes).to eq ""
      expect(tag.attributes(**{})).to eq ""
    end
  end

  describe "#link_to" do
    def link_to(...)
      described_class.link_to(...)
    end

    def tag(...)
      described_class.tag(...)
    end

    it "escapes href" do
      expect(link_to("content", "fo<o>bar")).to eq %(<a href="fo&lt;o&gt;bar">content</a>)
    end

    it "returns a link" do
      expect(link_to("Posts", "/posts")).to eq %(<a href="/posts">Posts</a>)
    end

    it "returns a link with a class" do
      expect(link_to("Post", "/posts", class: "first"))
        .to eq %(<a class="first" href="/posts">Post</a>)
    end

    it "returns a link with id" do
      expect(link_to("Post", "/posts", id: "posts__link"))
        .to eq %(<a id="posts__link" href="/posts">Post</a>)
    end

    it "returns a link relative link" do
      expect(link_to("Posts", "posts")).to eq %(<a href="posts">Posts</a>)
    end

    it "returns a link with html content" do
      expect(
        link_to("/posts") do
          tag.strong "Post"
        end
      ).to eq %(<a href="/posts"><strong>Post</strong></a>)
    end

    it "returns a link with html content, id and class" do
      expect(
        link_to("/posts", id: "posts__link", class: "first") do
          tag.strong "Post"
        end
      ).to eq %(<a id="posts__link" class="first" href="/posts"><strong>Post</strong></a>)
    end

    it "raises an exception link with content and html content" do
      expect {
        link_to("Posts", "/posts") do
          tag.strong "Posts"
        end
      }.to raise_error(ArgumentError)
    end

    it "raises an exception when link with content, html content, id and class" do
      expect {
        link_to("Post", "/posts", id: "posts__link", class: "first") do
          tag.strong "Post"
        end
      }.to raise_error(ArgumentError)
    end

    it "raises an exception when have not arguments" do
      expect { link_to }.to raise_error(ArgumentError)
    end

    it "raises an exception when have not arguments and empty block" do
      expect {
        link_to do
          # Block left intentionally blank
        end
      }.to raise_error(ArgumentError)
    end

    it "raises an exception when have only content" do
      expect { link_to("Post") }.to raise_error(ArgumentError)
    end

    describe "in templates" do
      let(:scope) {
        Class.new { include Hanami::View::Helpers::TagHelper }.new
      }

      def erb(str)
        Hanami::View::ERB::Template.new { str }.render(scope)
      end

      it "includes ordinary template content inside links" do
        src = <<~ERB
          <%= link_to "/posts" do %>
            Hello <strong>posts</strong>
            <% if false %>more<% end %>
          <% end %>
        ERB

        expect(erb(src)).to eq <<~HTML
          <a href="/posts">
            Hello <strong>posts</strong>
          </a>
        HTML
      end
    end
  end

  describe "#token_list" do
    def token_list(...)
      described_class.token_list(...)
    end

    it "combines array of tokens into a space-separated string" do
      expect(token_list(["ernie", "bert"])).to eq "ernie bert"
    end

    it "returns an html safe string" do
      expect(token_list(["ernie", "bert"])).to be_html_safe
    end

    it "aliased as class_names" do
      expect(described_class.class_names(["ernie", "bert"])).to eq token_list(["ernie", "bert"])
    end

    it "accepts an array of tokens as arguments" do
      expect(token_list("ernie", "bert")).to eq "ernie bert"
    end

    it "excludes nil values and empty strings" do
      expect(token_list([nil, "", "ernie"])).to eq "ernie"
    end

    it "includes hash keys with truthy values" do
      expect(token_list("ernie": true, "bert": false, "elmo": true)).to eq "ernie elmo"
      expect(token_list("ernie": false, "bert": false, "elmo": false)).to eq ""
    end

    it "combines an array and hash of values" do
      expect(token_list("ernie", "bert": true, "elmo": false)).to eq "ernie bert"
    end

    it "splits values on space-like characters" do
      expect(token_list("ernie\nbert")).to eq "ernie bert"
      expect(token_list("ernie\nbert" => true)).to eq "ernie bert"
    end

    it "escapes the tokens" do
      expect(token_list("ernie->bert")).to eq "ernie-&gt;bert"
    end

    it "does not escape html safe tokens" do
      expect(token_list("ernie->bert".html_safe)).to eq "ernie->bert"
    end

    it "does not repeatedly escape tokens from nested token_list calls" do
      expect(token_list("a->b", token_list("c->d", token_list("e->f"))))
        .to eq "a-&gt;b c-&gt;d e-&gt;f"
    end
  end
end
