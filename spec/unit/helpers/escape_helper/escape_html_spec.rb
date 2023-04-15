# frozen_string_literal: true

require "hanami/view/helpers/escape_helper"

RSpec.describe Hanami::View::Helpers::EscapeHelper, ".escape_html" do
  def escape_html(...)
    described_class.escape_html(...)
  end

  it "doesn't escape safe strings" do
    expect(escape_html("&".html_safe)).to eq "&"
  end

  it "escapes nil" do
    expect(escape_html(nil)).to eq ""
  end

  it "escapes 'test'" do
    expect(escape_html("test")).to eq "test"
  end

  it "escapes '&'" do
    expect(escape_html("&")).to eq "&amp;"
  end

  it "escapes '<'" do
    expect(escape_html("<")).to eq "&lt;"
  end

  it "escapes '>'" do
    expect(escape_html(">")).to eq "&gt;"
  end

  it %(escapes '"') do
    expect(escape_html('"')).to eq "&quot;"
  end

  it %(escapes "'") do
    expect(escape_html("'")).to eq "&#39;"

    # result = mod.html("'".encode(encoding))
    # expect(result).to eq "&apos;"
  end

  # it "escapes '/'" do
  #   result = mod.html("/".encode(encoding))
  #   expect(result).to eq "&#x2F;"
  # end

  it "escapes '<script>'" do
    expect(escape_html("<script>")).to eq "&lt;script&gt;"
  end

  it "escapes '<scr<script>ipt>'" do
    expect(escape_html("<scr<script>ipt>")).to eq "&lt;scr&lt;script&gt;ipt&gt;"
  end

  it "escapes '&lt;script&gt;'" do
    expect(escape_html("&lt;script&gt;")).to eq "&amp;lt;script&amp;gt;"
  end

  it "escapes '<script>alert('xss')</script>'" do
    expect(escape_html("<script>alert('xss')</script>")).to eq "&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;"

    # This test was copied from the tests for the (now-removed) `#escape_html_attribute`.
    #
    # When using that method, the result was:
    #
    # &lt;script&gt;alert&#x28;&#x27;xss&#x27;&#x29;&lt;&#x2f;script&gt;
    #
    # When using escape_html instead, the result is:
    #
    # &lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;
    #
    # This seems just as safe?
  end

  it %(escapes '""><script>xss(5)</script>') do
    expect(escape_html('""><script>xss(5)</script>')).to eq "&quot;&quot;&gt;&lt;script&gt;xss(5)&lt;/script&gt;"

    # '/' is kept verbatim above, but '&#x2F;' below from hanami-utils:
    #
    # result = mod.html('""><script>xss(5)</script>'.encode(encoding))
    # expect(result).to eq "&quot;&quot;&gt;&lt;script&gt;xss(5)&lt;&#x2F;script&gt;"
    #
    # This difference is the same for any other tests below with '/' present.
  end

  it %(escapes '><script>xss(6)</script>') do
    expect(escape_html("><script>xss(6)</script>")).to eq "&gt;&lt;script&gt;xss(6)&lt;/script&gt;"
  end

  it %(escapes '# onmouseover="xss(7)" ') do
    expect(escape_html('# onmouseover="xss(7)" ')).to eq "# onmouseover=&quot;xss(7)&quot; "
  end

  it %(escapes '/" onerror="xss(9)">') do
    expect(escape_html('/" onerror="xss(9)">')).to eq "/&quot; onerror=&quot;xss(9)&quot;&gt;"
  end

  it %(escapes '/ onerror="xss(10)"') do
    expect(escape_html('/ onerror="xss(10)"')).to eq "/ onerror=&quot;xss(10)&quot;"
  end

  it %(escapes '<<script>xss(14);//<</script>') do
    expect(escape_html("<<script>xss(14);//<</script>")).to eq "&lt;&lt;script&gt;xss(14);//&lt;&lt;/script&gt;"
  end

  # This test from hanami-utils fails. The code here does not force conversion of strings to UTF-8.
  # it "converts strings to UTF-8 encoding" do
  #   skip "There is no ASCII-8BIT encoding" unless Encoding.name_list.include?("ASCII-8BIT")
  #
  #   # 'тест' means test in russian
  #   string = "тест".dup.force_encoding("ASCII-8BIT")
  #   encoding = string.encoding
  #
  #   result = escape_html(string)
  #   expect(result).to eq "тест"
  #   expect(result.encoding).to eq Encoding::UTF_8
  #
  #   expect(string.encoding).to eq encoding
  # end
end
