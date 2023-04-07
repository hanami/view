# frozen_string_literal: true

RSpec.describe "Routing helper" do
  before do
    @actual = FullStack::Views::Dashboard::Index.render(format: :html)
  end

  it "uses helper" do
    expect(@actual).to include(%(/dashboard))
  end
end
