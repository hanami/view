require 'test_helper'

describe Lotus::View::Template::Finder do
  before do
    @root = Pathname.new(__dir__ + '/../../fixtures/templates').realpath
  end

  describe 'path' do
    it 'finds the template for the given class name' do
      file = Lotus::View::Template::Finder.new(RenderView, :html).find.file
      file.must_equal @root.join('render_view.html.erb').to_s
    end

    it 'finds the template for a namespaced class name' do
      file = Lotus::View::Template::Finder.new(App::View, :html).find.file
      file.must_equal @root.join('app/view.html.erb').to_s
    end

    it 'finds the template with a custom root' do
      file = Lotus::View::Template::Finder.new(AppView, :html).find.file
      file.must_equal @root.join('app/app_view.html.erb').to_s
    end
  end

  describe 'format' do
    describe 'per view configuration' do
      it 'finds the template for the specified format' do
        file = Lotus::View::Template::Finder.new(JsonRenderView, :json).find.file
        file.must_equal @root.join('json_render_view.json.erb').to_s
      end
    end

    describe 'inheritance' do
      it 'finds superclass templates' do
        file = Lotus::View::Template::Finder.new(Articles::Index, :html).find.file
        file.must_equal @root.join('articles/index.html.erb').to_s

        file = Lotus::View::Template::Finder.new(Articles::Index, :json).find.file
        file.must_equal @root.join('articles/index.json.erb').to_s
      end

      it 'finds subclass templates' do
        file = Lotus::View::Template::Finder.new(Articles::RssIndex, :rss).find.file
        file.must_equal @root.join('articles/index.rss.erb').to_s
      end

      it 'finds grandchild templates' do
        file = Lotus::View::Template::Finder.new(Articles::AtomIndex, :atom).find.file
        file.must_equal @root.join('articles/index.atom.erb').to_s
      end
    end
  end
end
