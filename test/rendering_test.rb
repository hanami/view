require 'test_helper'
require 'ostruct'

describe Lotus::View do
  describe 'rendering' do
    it 'renders a template' do
      HelloWorldView.render({format: :html}, {}).must_include %(<h1>Hello, World!</h1>)
    end

    it 'renders a template with context binding' do
      RenderView.render({format: :html}, {planet: 'Mars'}).must_include %(<h1>Hello, Mars!</h1>)
    end

    it 'renders a template according to the declared format' do
      JsonRenderView.render({format: :json}, {planet: 'Moon'}).must_include %("greet":"Hello, Moon!")
    end

    it 'renders a template according to the requested format' do
      articles = [ OpenStruct.new(title: 'Man on the Moon!') ]

      rendered = Articles::Index.render({format: :json}, {articles: articles})
      rendered.must_match %("title":"Man on the Moon!")

      rendered = Articles::Index.render({format: :html}, {articles: articles})
      rendered.must_match %(<h1>Man on the Moon!</h1>)
    end

    it 'binds given locals to the rendering context' do
      article = OpenStruct.new(title: 'Hello')

      rendered = Articles::Show.render({format: :html}, {article: article})
      rendered.must_match %(<h1>HELLO</h1>)
    end

    it 'renders a template from a subclass, if it is able to handle the requested format' do
      article = OpenStruct.new(title: 'Hello')

      rendered = Articles::Show.render({format: :json}, {article: article})
      rendered.must_match %("title":"olleh")
    end

    it 'returns nil when context conditions cannot be met' do
      article = OpenStruct.new(title: 'Ciao')

      rendered = Articles::Show.render({format: :png}, {article: article})
      rendered.must_be_nil
    end

    it 'renders different template, as specified by DSL' do
      article = OpenStruct.new(title: 'Bonjour')

      rendered = Articles::Create.render({format: :html}, {article: article})
      rendered.must_match %(<h1>New Article</h1>)
      rendered.must_match %(<h2>Errors</h2>)
    end
  end
end
