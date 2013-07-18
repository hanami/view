require 'test_helper'

describe Lotus::View do
  before do
    @root = Pathname.new __dir__ + '/fixtures/templates'
  end

  it 'has a root where to look for templates' do
    Lotus::View.root.must_equal @root
  end

  it 'renders template for the given context' do
    result  = RenderView.new.render({ format: :html }, { planet: 'World' })
    result.must_equal "<h1>Hello, World!</h1>\n"
  end
end
