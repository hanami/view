# frozen_string_literal: true

RSpec.describe Hanami::Helpers::HtmlHelper::HtmlBuilder do
  ##############################################################################
  # TAGS                                                                       #
  ##############################################################################

  describe "content tag" do
    it "always closes tag, without any argument" do
      actual = subject.div
      expect(actual).to eq(%(<div></div>))
    end

    it "always closes tag, with empty block" do
      actual = subject.div {}
      expect(actual).to eq(%(<div></div>))
    end

    it "always closes tag, with string content" do
      actual = subject.div("Hello")
      expect(actual).to eq(%(<div>Hello</div>))
    end

    it "always closes tag, with string content and attributes" do
      actual = subject.div("Hello", id: "foo")
      expect(actual).to eq(%(<div id="foo">Hello</div>))
    end

    it "always closes tag, with block content and attributes" do
      actual = subject.div(id: "foo") { text "Hello" }
      expect(actual).to eq(%(<div id="foo">Hello</div>))
    end

    it "always closes tag, with nested tag" do
      actual = subject.div(id: "foo") { span "Hello" }
      expect(actual).to eq(%(<div id="foo"><span>Hello</span></div>))
    end
  end

  describe "empty tag" do
    it "does not closes tag, without any argument" do
      actual = subject.br
      expect(actual).to eq(%(<br>))
    end

    it "does not closes tag, with empty block" do
      actual = subject.br {}
      expect(actual).to eq(%(<br>))
    end

    it "does not closes tag, and ignores block content" do
      actual = subject.br { text "Hello" }
      expect(actual).to eq(%(<br>))
    end

    it "does not closes tag, with attributes" do
      actual = subject.br(id: "foo")
      expect(actual).to eq(%(<br id="foo">))
    end
  end

  describe "#tag" do
    it "generates it" do
      result = subject.tag(:custom, "Foo", id: "content").to_s
      expect(result).to eq(%(<custom id="content">Foo</custom>))
    end
  end

  describe "<a>" do
    it "generates a link" do
      result = subject.a("Hanami", href: "http://hanamirb.org").to_s
      expect(result).to eq(%(<a href="http://hanamirb.org">Hanami</a>))
    end

    it "generates a link with target" do
      result = subject.a("Hanami", href: "http://hanamirb.org", target: "_blank").to_s
      expect(result).to eq(%(<a href="http://hanamirb.org" target="_blank">Hanami</a>))
    end

    it "generates a link with image" do
      result = subject.a("Hanami", href: "http://hanamirb.org") do
        img(src: "/images/logo.png")
      end.to_s

      expect(result).to eq(%(<a href="http://hanamirb.org"><img src="/images/logo.png"></a>))
    end
  end

  describe "<abbr>" do
    it "generates an abbreviation" do
      result = subject.abbr("MVC", title: "Model View Controller").to_s
      expect(result).to eq(%(<abbr title="Model View Controller">MVC</abbr>))
    end
  end

  describe "<addr>" do
    it "generates an address" do
      content = Hanami::Helpers::Escape.safe_string(
        <<~CONTENT
          Mozilla Foundation<br>
          1981 Landings Drive<br>
          Building K<br>
          Mountain View, CA 94043-0801<br>
          USA
        CONTENT
      )

      result = subject.address(content).to_s
      expect(result).to eq(%(<address>#{content}</address>))
    end
  end

  describe "<script>" do
    it "generates a script tag with a link to a javascript" do
      result = subject.script(src: "/assets/application.js").to_s
      expect(result).to eq(%(<script src="/assets/application.js"></script>))
    end

    it "generates a script tag with javascript code" do
      result = subject.script { text Hanami::Helpers::Escape.safe_string(%(alert("hello"))) }.to_s
      expect(result).to eq(%(<script>alert("hello")</script>))
    end
  end

  describe "<template>" do
    it "generates a template tag" do
      result = subject.template(id: "product") do
        div "Computer"
      end.to_s

      expect(result).to eq(%(<template id="product"><div>Computer</div></template>))
    end

    it "generates a script tag with javascript code" do
      result = subject.script { text Hanami::Helpers::Escape.safe_string(%(alert("hello"))) }.to_s
      expect(result).to eq(%(<script>alert("hello")</script>))
    end
  end

  describe "<title>" do
    it "generates a title" do
      result = subject.title("Welcome to Foo").to_s
      expect(result).to eq(%(<title>Welcome to Foo</title>))
    end
  end

  describe "<dialog>" do
    it "generates a dialog" do
      result = subject.dialog("Greetings, one and all!").to_s
      expect(result).to eq(%(<dialog>Greetings, one and all!</dialog>))
    end
  end

  describe "<hgroup>" do
    it "generates a hgroup" do
      result = subject.hgroup do
        h1 "Hello"
      end.to_s

      expect(result).to eq(%(<hgroup><h1>Hello</h1></hgroup>))
    end
  end

  describe "<rtc>" do
    it "generates a rtc" do
      result = subject.rtc("Rome").to_s
      expect(result).to eq(%(<rtc>Rome</rtc>))
    end
  end

  describe "<slot>" do
    it "generates a slot" do
      result = subject.slot("Need description").to_s
      expect(result).to eq(%(<slot>Need description</slot>))
    end
  end

  describe "<var>" do
    it "generates a var" do
      result = subject.var("x").to_s
      expect(result).to eq(%(<var>x</var>))
    end
  end

  ##############################################################################
  # EMPTY TAGS                                                                 #
  ##############################################################################

  describe "#empty_tag" do
    it "generates it" do
      result = subject.empty_tag(:xr, id: "foo").to_s
      expect(result).to eq(%(<xr id="foo">))
    end
  end

  describe "<img>" do
    it "generates an image" do
      result = subject.img(src: "/images/logo.png", alt: "Hanami logo").to_s
      expect(result).to eq(%(<img src="/images/logo.png" alt="Hanami logo">))
    end

    it "generates an image with size" do
      result = subject.img(src: "/images/logo.png", height: 128, width: 128).to_s
      expect(result).to eq(%(<img src="/images/logo.png" height="128" width="128">))
    end
  end

  describe "<link>" do
    it "generates a link to a stylesheet" do
      result = subject.link(href: "/assets/application.css", rel: "stylesheet").to_s
      expect(result).to eq(%(<link href="/assets/application.css" rel="stylesheet">))
    end
  end

  describe "<meta>" do
    it "generates HTML4 content type" do
      # RUBY_VERSION >= 2.2
      # result = subject.meta('http-equiv': 'Content-Type', content: 'text/html; charset=utf-8').to_s
      result = subject.meta("http-equiv": "Content-Type", content: "text/html; charset=utf-8").to_s
      expect(result).to eq(%(<meta http-equiv="Content-Type" content="text/html; charset=utf-8">))
    end

    it "generates HTML5 content type" do
      result = subject.meta(charset: "utf-8").to_s
      expect(result).to eq(%(<meta charset="utf-8">))
    end

    it "generates a page refresh" do
      result = subject.meta("http-equiv": "refresh", content: "23;url=http://hanamirb.org").to_s
      expect(result).to eq(%(<meta http-equiv="refresh" content="23;url=http://hanamirb.org">))
    end
  end

  ##############################################################################
  # FRAGMENTS
  ##############################################################################

  describe "fragment" do
    it "generates a html fragment" do
      result = subject.fragment do
        span "Hello"
        span "Hanami"
      end.to_s

      expect(result).to eq(%(<span>Hello</span><span>Hanami</span>))
    end
  end

  ##############################################################################
  # ATTRIBUTES                                                                 #
  ##############################################################################

  describe "attributes" do
    it "handles no attribute list" do
      result = subject.div.to_s
      expect(result).to eq("<div></div>")
    end

    it "handles empty attribute list" do
      result = subject.div({}).to_s
      expect(result).to eq("<div></div>")
    end

    it "handles nil attribute list" do
      result = subject.div(nil).to_s
      expect(result).to eq("<div></div>")
    end

    it "does not render boolean attribute when its value is false" do
      result = subject.input(required: false).to_s
      expect(result).to eq("<input>")
    end

    it "does not render boolean attribute when its value is nil" do
      result = subject.input(required: nil).to_s
      expect(result).to eq("<input>")
    end

    it "does render boolean attribute when its value is true" do
      result = subject.input(required: true).to_s
      expect(result).to eq("<input required>")
    end

    it "also handles strings for detection of boolean attributes" do
      result = subject.input("required" => true).to_s
      expect(result).to eq("<input required>")
    end

    it "renders multiple attributes" do
      result = subject.input("required" => true, "value" => 'Title "book"', "something" => "bar").to_s
      expect(result).to eq('<input required value="Title "book"" something="bar">')
    end

    it "renders empty node with array value as joined with space" do
      result = subject.input("class" => [:ui, :form]).to_s
      expect(result).to eq('<input class="ui form">')
    end

    it "renders non-empty node with array value as joined with space" do
      result = subject.span("foo", "class" => [:ui, :form]).to_s
      expect(result).to eq('<span class="ui form">foo</span>')
    end
  end

  ##############################################################################
  # TEXT
  ##############################################################################

  describe "plain text" do
    it "renders plain text" do
      result = subject.text("Foo").to_s
      expect(result).to eq("Foo")
    end

    it "accepts any object that respond to #to_s" do
      result = subject.text(23).to_s
      expect(result).to eq("23")
    end

    it "renders plain text inside a tag" do
      result = subject.p do
        span("Foo")
        text("Bar")
      end.to_s

      expect(result).to eq(%(<p><span>Foo</span>Bar</p>))
    end

    it "ignores block" do
      result = subject.text("Foo") { p "Bar" }.to_s
      expect(result).to eq("Foo")
    end

    it "allows concatenation with text" do
      result = subject.p do
        span("Foo") +
          text("Bar")
      end.to_s

      expect(result).to eq(%(<p><span>Foo</span>Bar</p>))
    end

    it "escapes HTML inside" do
      result = subject.text(%(<p>Foo</p>)).to_s
      expect(result).to eq("&lt;p&gt;Foo&lt;/p&gt;")
    end
  end
end
