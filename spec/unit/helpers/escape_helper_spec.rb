# frozen_string_literal: true

RSpec.describe Hanami::Helpers::EscapeHelper do
  before do
    @view = EscapeView.new
  end

  it "has a private escape html method" do
    expect { @view.escape_html }.to raise_error(NoMethodError)
  end

  it "has a private escape html attribute method" do
    expect { @view.escape_html_attribute }.to raise_error(NoMethodError)
  end

  it "has a private escape url method" do
    expect { @view.escape_url }.to raise_error(NoMethodError)
  end

  it "has a private raw method" do
    expect { @view.raw }.to raise_error(NoMethodError)
  end

  it "autoscape evil string" do
    expect(@view.evil_string).to eq(%(&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;))
  end

  it "don't autoscape safe string" do
    expect(@view.good_string).to eq(%(this is a good string))
  end

  it "autoscape attributes evil string" do
    expect(@view.good_attributes_string).to eq(%(<a title='foo'>link</a>))
  end

  it "don't autoscape attributes safe string" do
    expect(@view.evil_attributes_string).to eq(%(<a title='&lt;script&gt;alert&#x28;&#x27;xss&#x27;&#x29;&lt;&#x2f;script&gt;'>link</a>))
  end

  it "autoscape url evil string" do
    expect(@view.good_url_string).to eq(%(http://hanamirb.org))
  end

  it "don't autoscape url evil string" do
    expect(@view.evil_url_string).to be_empty
  end

  it "raw string is returned" do
    expect(@view.raw_string).to eq(%(<div>I'm a raw string</div>))
  end

  it "raw string is a Temple::HTML::SafeString class" do
    expect(@view.raw_string.class).to eq(Temple::HTML::SafeString)
  end

  it "html helper alias" do
    expect(@view.html_string_alias).to eq(%(this is a good string))
  end

  it "html attribute helper alias" do
    expect(@view.html_attribute_string_alias).to eq(%(<a title='foo'>link</a>))
  end

  it "url helper alias" do
    expect(@view.url_string_alias).to eq(%(http://hanamirb.org))
  end
end
