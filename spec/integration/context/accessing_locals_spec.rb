# frozen_string_literal: true

RSpec.describe "Context / Accessing locals" do
  let(:view) {
    Class.new(Hanami::View) {
      config.paths = FIXTURES_PATH.join("integration/context/accessing_locals")
      config.template = "accessing_locals"

      expose :text, decorate: false
    }.new
  }

  it "provides access to all locals as a hash" do
    expect(view.(text: "Hello").to_s).to eq (<<~TEXT).strip
      Locals from context: {:text=>"Hello"}<br />Locals from context in partial: {:partial_local=>"hello"}
    TEXT
  end
end
