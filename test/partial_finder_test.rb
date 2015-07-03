require 'test_helper'

describe Lotus::View::Rendering::PartialFinder do
  it 'finds the correct partial' do
    path     = Organisations::OrderTemplates::Action.root.join('organisations/order_templates/action.html.erb')
    template = Lotus::View::Template.new(path)

    inner_resource_action = Organisations::OrderTemplates::Action.new(template, {})

    partial_finder = Lotus::View::Rendering::PartialFinder.new(Organisations::OrderTemplates::Action, partial: 'partial', format: 'html')
    partial_finder.find.render(format: 'html').must_match 'Order Template Partial'

    partial_finder = Lotus::View::Rendering::PartialFinder.new(Organisations::Action, partial: 'partial', format: 'html')
    partial_finder.find.render(format: 'html').must_match 'Organisation Partial'
  end
end
