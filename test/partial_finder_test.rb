require 'test_helper'

describe Hanami::View::Rendering::PartialFinder do
  it 'finds the correct partial' do
    partial_finder = Hanami::View::Rendering::PartialFinder.new(Organisations::OrderTemplates::Action, partial: 'partial', format: 'html')
    partial_finder.find.render(format: 'html').must_match 'Order Template Partial'

    partial_finder = Hanami::View::Rendering::PartialFinder.new(Organisations::Action, partial: 'partial', format: 'html')
    partial_finder.find.render(format: 'html').must_match 'Organisation Partial'
  end
end
