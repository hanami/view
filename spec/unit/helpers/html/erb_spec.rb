# frozen_string_literal: true

RSpec.describe "HTML Helper: ERB" do
  let(:view) { HTMLTemplate.new }
  let(:template) { Tilt.new(TEMPLATES_PATH.join("html.erb")) }

  xit "renders multi block HTML" do
    actual = template.render(view)
    expected = %(<div id="greeting">\n\n  <p>Hello world</p>\n\n</div>\n)

    expect(actual).to eq(expected)
  end
end
