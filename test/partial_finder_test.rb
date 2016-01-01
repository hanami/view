require 'test_helper'

describe Lotus::View::Rendering::PartialFinder do
  it 'finds the correct partial in the same directory as the parent view' do
    partial_finder = Lotus::View::Rendering::PartialFinder.new(Organisations::OrderTemplates::Action, partial: 'partial', format: 'html')
    partial_finder.find.render(format: 'html').must_match 'Order Template Partial'

    partial_finder = Lotus::View::Rendering::PartialFinder.new(Organisations::Action, partial: 'partial', format: 'html')
    partial_finder.find.render(format: 'html').must_match 'Organisation Partial'
  end

  it 'finds the correct partial in a different directory to the parent view' do
    partial_finder = Lotus::View::Rendering::PartialFinder.new(Organisations::OrderTemplates::Action, partial: 'shared/sidebar', format: 'html')
    partial_finder.find.render(format: 'html').must_match '<div id="sidebar"></div>'
  end
end
