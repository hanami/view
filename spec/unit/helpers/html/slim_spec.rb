# frozen_string_literal: true

require "temple/html/safe"

RSpec.describe "HTML Helper: Slim" do
  let(:view) { HTMLTemplate.new }
  let(:template) { Tilt.new(TEMPLATES_PATH.join("html.slim")) }

  xit "renders multi block HTML" do
    actual = template.render(view)
    expected = %(<div id="greeting">\n\n  <p>Hello world</p>\n\n</div>\n)

    expect(actual).to eq(expected)
  end
end
