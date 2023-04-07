# frozen_string_literal: true

RSpec.describe "Number formatting helper" do
  subject(:view) {
    Class.new(Hanami::View) do
      config.paths = TEMPLATES_PATH
      config.template = "cart/show"

      expose :total do |total:|
        # format_number(total) # NoMethodError for View class
        total
      end
    end.new
  }

  let(:ctx) do
    Class.new(Hanami::View::Context) {
      include Hanami::Helpers
    }.new
  end

  describe "#call" do
    it "renders template within the layout" do
      actual = view.(context: ctx, total: 1234.56).to_s

      expect(actual).to match("1,234.56")
    end
  end
end
