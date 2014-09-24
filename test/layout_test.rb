require 'test_helper'

describe Lotus::Layout do
  describe 'rendering from layout' do
    it 'renders partial' do
      rendered = IndexView.render(format: :html)
      rendered.must_match %(<div id="sidebar"></div>)
    end
  end

  it 'concrete methods are available in layout template' do
    rendered = Store::Views::Home::Index.render(format: :html)
    rendered.must_match %(yeah)
  end
end
