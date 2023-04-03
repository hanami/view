# frozen_string_literal: true

RSpec.describe Hanami::View::HTML, ".escape_html" do
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
  end

  it "escapes '<script>'" do
    expect(escape_html("<script>")).to eq "&lt;script&gt;"
  end

  it "escapes '<scr<script>ipt>'" do
    expect(escape_html("<scr<script>ipt>")).to eq "&lt;scr&lt;script&gt;ipt&gt;"
  end

  it "escapes '&lt;script&gt;'" do
    expect(escape_html("&lt;script&gt;")).to eq "&amp;lt;script&amp;gt;"
  end

  it %(escapes '""><script>xss(5)</script>') do
    expect(escape_html('""><script>xss(5)</script>')).to eq "&quot;&quot;&gt;&lt;script&gt;xss(5)&lt;/script&gt;"
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
end
