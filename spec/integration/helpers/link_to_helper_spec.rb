# frozen_string_literal: true

RSpec.describe "Escape helper" do
  before do
    @user   = LinkTo.new
    @actual = LinkTo::Index.render(format: :html)
  end

  it "renders the title" do
    expect(@actual).to match(%(<a href="/">Home</a>))
  end

  it "renders relative link" do
    expect(@actual).to match(%(<a href="relative">Relative</a>))
  end

  it "renders link using html content" do
    expect(@actual).to match(%(<a href="/">\n<p>Home with html content</p>\n</a>))
  end

  it "renders link using html content, id and class" do
    expect(@actual).to match(%(<a id="home__link" class="first" href="/">\n<p>Home with html content, id and class</p>\n</a>))
  end

  it "renders link using content" do
    expect(@actual).to match(%(<a href="http://external.com">External</a>))
  end

  it "renders link using html content" do
    expect(@actual).to match(%(<a href="http://external.com">\n<strong>External with html content</strong>\n</a>))
  end

  it "escapes content" do
    expect(@actual).to include(%(<a href="/">&lt;script&gt;alert(&apos;xss&apos;)&lt;&#x2F;script&gt;</a>))
  end

  it "escapes raw block content" do
    expect(@actual).to include(%(<a href="/">\n&lt;script&gt;alert(&apos;xss2&apos;)&lt;&#x2F;script&gt;\n</a>))
  end

  it "escapes html builder block content" do
    expect(@actual).to include(%(<a href="/">\n<p>&lt;script&gt;alert(&apos;xss3&apos;)&lt;&#x2F;script&gt;</p>\n</a>))
  end
end
