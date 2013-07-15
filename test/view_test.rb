require 'test_helper'

describe Lotus::View do
  before do
    @root = Pathname.new __dir__ + '/fixtures/templates'
    Lotus::View.root = @root.to_s

    class RenderView
      include Lotus::View
    end
  end

  it 'has a root where to look for templates' do
    Lotus::View.root.must_equal @root
  end

  it 'has a path for its template' do
    RenderView.path.must_equal @root.join 'render_view.erb'
  end

  it 'raises an exception if the template is missing' do
    ->() {
      class MissingTemplate
        include Lotus::View
      end
    }.must_raise Lotus::View::MissingTemplateError
  end

  it 'renders an Hash context with a template' do
    result = RenderView.new.render(planet: 'World')
    result.must_equal "<h1>Hello, World!</h1>\n"
  end
end
