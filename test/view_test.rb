require 'test_helper'

describe Lotus::View do
  before do
    @root = Pathname.new __dir__ + '/fixtures/templates'
  end

  it 'has a root where to look for templates' do
    Lotus::View.root.must_equal @root
  end

  it 'renders an Hash context with a template' do
    result = RenderView.new.render(planet: 'World')
    result.must_equal "<h1>Hello, World!</h1>\n"
  end
end
