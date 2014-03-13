require 'test_helper'

describe Lotus::View::Layout do
  describe 'rendering from layout' do
    it 'renders partial' do
      rendered = IndexView.render({format: :html}, {})
      rendered.must_match %(<div id="sidebar"></div>)
    end
  end
end
