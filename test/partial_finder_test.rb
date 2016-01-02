require 'test_helper'

describe Lotus::View::Rendering::PartialFinder do
  before do
    Lotus::View.unload!
    Lotus::View.class_eval do
      configure do
        root Pathname.new __dir__ + '/fixtures/templates'
      end
    end

    Lotus::View.load!
  end

  it 'finds the correct partial in the same directory as the parent view' do
    partial_finder = Lotus::View::Rendering::PartialFinder.new(Organisations::OrderTemplates::Action, partial: 'partial', format: 'html')
    partial_finder.find.render({}).must_match 'Order Template Partial'

    partial_finder = Lotus::View::Rendering::PartialFinder.new(Organisations::Action, partial: 'partial', format: 'html')
    partial_finder.find.render({}).must_match 'Organisation Partial'
  end

  it 'finds the correct partial in a different directory to the parent view' do
    partial_finder = Lotus::View::Rendering::PartialFinder.new(Organisations::OrderTemplates::Action, partial: 'shared/sidebar', format: 'html')
    partial_finder.find.render({}).must_match '<div id="sidebar"></div>'
  end

  it 'finds the correct partial with a different format' do
    partial_finder = Lotus::View::Rendering::PartialFinder.new(Organisations::OrderTemplates::Action, partial: 'shared/sidebar', format: 'json')
    partial_finder.find.render({}).must_match '{ "sidebar": [] }'
  end

  it 'finds the correct partial from the cache rather than reading from the file system' do
    partial_finder = Lotus::View::Rendering::PartialFinder.new(Organisations::OrderTemplates::Action, partial: 'partial', format: 'html')
    partial_finder.send(:find_cached_template).wont_be_nil
    partial_finder = Lotus::View::Rendering::PartialFinder.new(Organisations::OrderTemplates::Action, partial: 'shared/sidebar', format: 'html')
    partial_finder.send(:find_cached_template).wont_be_nil
    partial_finder = Lotus::View::Rendering::PartialFinder.new(Organisations::OrderTemplates::Action, partial: 'shared/sidebar', format: 'json')
    partial_finder.send(:find_cached_template).wont_be_nil
  end
end
