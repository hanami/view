require 'test_helper'

describe Lotus::View::Template::Finder do
  before do
    @root = Pathname.new(__dir__ + '/../../fixtures/templates').realpath
  end

  describe 'path' do
    it 'finds the template for the given class name' do
      finder = Lotus::View::Template::Finder.new(RenderView)
      finder.find.must_equal([@root.join('render_view.html.erb')])
    end

    it 'finds the template for a namespaced class name' do
      finder = Lotus::View::Template::Finder.new(App::View)
      finder.find.must_equal([@root.join('app/view.html.erb')])
    end

    it 'finds the template with a custom root' do
      finder = Lotus::View::Template::Finder.new(AppView)
      finder.find.must_equal([@root.join('app/app_view.html.erb')])
    end

    it 'raises an error when the template is missing' do
      finder = Lotus::View::Template::Finder.new(MissingTemplateView)
      -> { finder.find }.must_raise Lotus::View::MissingTemplateError
    end
  end

  describe 'format' do
    describe 'per view configuration' do
      it 'finds the template for the specified format' do
        finder = Lotus::View::Template::Finder.new(JsonRenderView)
        finder.find.must_equal([@root.join('json_render_view.json.erb')])
      end
    end
  end
end
