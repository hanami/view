require 'test_helper'
require 'ostruct'

describe Lotus::View do
  describe 'rendering' do
    it 'renders a template' do
      HelloWorldView.render(format: :html).must_include %(<h1>Hello, World!</h1>)
    end

    it 'renders a template with context binding' do
      RenderView.render(format: :html, planet: 'Mars').must_include %(<h1>Hello, Mars!</h1>)
    end

    it 'renders a template according to the declared format' do
      JsonRenderView.render(format: :json, planet: 'Moon').must_include %("greet":"Hello, Moon!")
    end

    it 'renders a template according to the requested format' do
      articles = [ OpenStruct.new(title: 'Man on the Moon!') ]

      rendered = Articles::Index.render(format: :json, articles: articles)
      rendered.must_match %("title":"Man on the Moon!")

      rendered = Articles::Index.render(format: :html, articles: articles)
      rendered.must_match %(<h1>Man on the Moon!</h1>)
    end

    describe 'calling an action method from the template' do
      it 'can call with multiple arguments' do
        RenderViewMethodWithArgs.render({format: :html}).must_include %(<h1>Hello, earth!</h1>)
      end

      it 'will override Kernel methods' do
        RenderViewMethodOverride.render({format: :html}).must_include %(<h1>Hello, foo!</h1>)
      end

      it 'can call with block' do
        RenderViewMethodWithBlock.render({format: :html}).must_include %(<ul><li>thing 1</li><li>thing 2</li><li>thing 3</li></ul>)
      end
    end

    it 'binds given locals to the rendering context' do
      article = OpenStruct.new(title: 'Hello')

      rendered = Articles::Show.render(format: :html, article: article)
      rendered.must_match %(<h1>HELLO</h1>)
    end

    it 'renders a template from a subclass, if it is able to handle the requested format' do
      article = OpenStruct.new(title: 'Hello')

      rendered = Articles::Show.render(format: :json, article: article)
      rendered.must_match %("title":"olleh")
    end

    it 'raises an error when the template is missing' do
      article = OpenStruct.new(title: 'Ciao')

      -> {
        Articles::Show.render(format: :png, article: article)
      }.must_raise(Lotus::View::MissingTemplateError)
    end

    it 'raises an error when the format is missing' do
      -> {
        HelloWorldView.render({})
      }.must_raise(Lotus::View::MissingFormatError)
    end

    it 'renders different template, as specified by DSL' do
      article = OpenStruct.new(title: 'Bonjour')

      rendered = Articles::Create.render(format: :html, article: article)
      rendered.must_match %(<h1>New Article</h1>)
      rendered.must_match %(<h2>Errors</h2>)
    end

    it 'finds and renders template in nested directories' do
      rendered = NestedView.render(format: :html)
      rendered.must_match %(<h1>Nested</h1>)
    end

    it 'decorates locals' do
      map = Map.new(['Rome', 'Cambridge'])

      rendered = Dashboard::Index.render(format: :html, map: map)
      rendered.must_match %(<h1>Map</h1>)
      rendered.must_match %(<h2>2 locations</h2>)
    end

    it 'renders a partial' do
      article = OpenStruct.new(title: nil)

      rendered = Articles::New.render(format: :html, article: article)

      rendered.must_match %(<h1>New Article</h1>)
      rendered.must_match %(<input type="hidden" name="secret" value="23" />)
    end

    # @issue https://github.com/lotus/view/issues/3
    it 'renders a template within another template' do
      parent = OpenStruct.new(children: [], name: 'parent')
      child1 = OpenStruct.new(children: [], name: 'child1')
      child2 = OpenStruct.new(children: [], name: 'child2')

      parent.children.push(child1)
      parent.children.push(child2)

      rendered = Nodes::Parent.render(format: :html, node: parent)

      rendered.must_match %(<h1>parent</h1>)
      rendered.must_match %(<li>child1</li>)
      rendered.must_match %(<li>child2</li>)
    end

    it 'uses HAML engine' do
      person = OpenStruct.new(name: 'Luca')

      rendered = Contacts::Show.render(format: :html, person: person)
      rendered.must_match %(<h1>Luca</h1>)
    end

    describe 'when without a template' do
      it 'renders from the custom rendering method' do
        song = OpenStruct.new(title: 'Song Two', url: '/song2.mp3')

        rendered = Songs::Show.render(format: :html, song: song)
        rendered.must_equal %(<audio src="/song2.mp3">Song Two</audio>)
      end

      it 'respond to all the formats' do
        rendered = Metrics::Index.render(format: :html)
        rendered.must_equal %(metrics)

        rendered = Metrics::Index.render(format: :json)
        rendered.must_equal %(metrics)
      end
    end

    describe 'layout' do
      it 'renders contents from layout' do
        articles = [ OpenStruct.new(title: 'A Wonderful Day!') ]

        rendered = Articles::Index.render(format: :html, articles: articles)
        rendered.must_match %(<h1>A Wonderful Day!</h1>)
        rendered.must_match %(<html>)
        rendered.must_match %(<title>Title: articles</title>)
      end
    end
  end
end
