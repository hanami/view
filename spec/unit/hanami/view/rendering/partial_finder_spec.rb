RSpec.describe Hanami::View::Rendering::PartialFinder do
  include_context "reload configuration"

  it "finds the correct partial in the same directory as the parent view" do
    partial_finder = Hanami::View::Rendering::PartialFinder.new(Organisations::OrderTemplates::Action, partial: "partial", format: "html")
    expect(partial_finder.find.render({})).to match "Order Template Partial"

    partial_finder = Hanami::View::Rendering::PartialFinder.new(Organisations::Action, partial: "partial", format: "html")
    expect(partial_finder.find.render({})).to match "Organisation Partial"
  end

  it "finds the correct partial in a different directory to the parent view" do
    partial_finder = Hanami::View::Rendering::PartialFinder.new(Organisations::OrderTemplates::Action, partial: "shared/sidebar", format: "html")
    expect(partial_finder.find.render({})).to match '<div id="sidebar"></div>'
  end

  it "finds the correct partial with a different format" do
    partial_finder = Hanami::View::Rendering::PartialFinder.new(Organisations::OrderTemplates::Action, partial: "shared/sidebar", format: "json")
    expect(partial_finder.find.render({})).to match '{ "sidebar": \[\] }'
  end

  it "finds the correct partial from the cache rather than reading from the file system" do
    partial_finder = Hanami::View::Rendering::PartialFinder.new(Organisations::OrderTemplates::Action, partial: "partial", format: "html")
    expect(partial_finder.find).to_not be_nil
    partial_finder = Hanami::View::Rendering::PartialFinder.new(Organisations::OrderTemplates::Action, partial: "shared/sidebar", format: "html")
    expect(partial_finder.find).to_not be_nil
    partial_finder = Hanami::View::Rendering::PartialFinder.new(Organisations::OrderTemplates::Action, partial: "shared/sidebar", format: "json")
    expect(partial_finder.find).to_not be_nil
  end
end
