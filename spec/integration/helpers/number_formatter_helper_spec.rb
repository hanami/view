# frozen_string_literal: true

require "hanami/view/helpers/number_formatting_helper"

RSpec.describe Hanami::View::Helpers::NumberFormattingHelper do
  before :all do
    @dir = make_tmp_directory

    with_directory(@dir) do
      write "number_formatting_helper.html.erb", <<~ERB
        <%= format_number(number) %>
      ERB
    end
  end

  subject(:view) {
    dir = self.dir
    part_class = self.part_class
    scope_class = self.scope_class

    Class.new(Hanami::View) do
      config.paths = dir
      config.template = "number_formatting_helper"
      config.part_class = part_class
      config.scope_class = scope_class

      expose :number
    end.new
  }

  let(:dir) { @dir }

  let(:part_class) {
    helper = self.described_class

    Class.new(Hanami::View::Part) {
      include helper
    }
  }

  let(:scope_class) {
    helper = self.described_class

    Class.new(Hanami::View::Scope) {
      include helper
    }
  }

  it "works" do
    expect(view.(number: 12_300).to_s.strip).to eq "12,300"
  end
end
