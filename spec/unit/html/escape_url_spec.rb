# frozen_string_literal: true

RSpec.describe Hanami::View::HTML, ".escape_url" do
  def escape_url(...)
    described_class.escape_url(...)
  end

  it "doesn't escape safe strings" do
    expect(escape_url("javascript:alert(0);".html_safe)).to eq "javascript:alert(0);"
  end

  it "escapes nil" do
    expect(escape_url(nil)).to eq ""
  end

  it "escapes 'test'" do
    expect(escape_url("test")).to eq ""
  end

  describe "acceptable URLs" do
    URLS = %w[
      http://hanamirb.org
      https://hanamirb.org
      https://hanamirb.org#introduction
      https://hanamirb.org/guides/index.html
      mailto:user@example.com
      mailto:user@example.com?Subject=Hello
    ]

    it "returns a safe string" do
      expect(escape_url(URLS.first)).to be_html_safe
    end

    URLS.each do |url|
      it %(accepts "#{url}") do
        expect(escape_url(url)).to eq url
      end
    end
  end

  describe "unacceptable URLs" do
    it "returns a safe string" do
      expect(escape_url("javascript:alert(1);")).to be_html_safe
    end

    it "escapes 'javascript:alert(1);'" do
      expect(escape_url("javascript:alert(1);")).to eq ""
    end

    # See https://github.com/mzsanford/twitter-text-rb/commit/cffce8e60b7557e9945fc0e8b4383e5a66b1558f
    it %(escapes 'http://x.xx/@"style="color:pink"onmouseover=alert(1)//') do
      expect(escape_url('http://x.xx/@"style="color:pink"onmouseover=alert(1)//')).to eq "http://x.xx/@"
    end

    it %{escapes 'http://x.xx/("style="color:red"onmouseover="alert(1)'} do
      expect(escape_url('http://x.xx/("style="color:red"onmouseover="alert(1)')).to eq "http://x.xx/("
    end

    it %(escapes 'http://x.xx/@%22style=%22color:pink%22onmouseover=alert(1)//') do
      expect(escape_url("http://x.xx/@%22style=%22color:pink%22onmouseover=alert(1)//")).to eq "http://x.xx/@"
    end
  end
end
