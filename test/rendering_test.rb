require 'test_helper'
require 'ostruct'

describe Lotus::View do
  describe 'rendering' do
    before do
      @articles = [
        OpenStruct.new(title: "Alien Invasion!"),
        OpenStruct.new(title: "No, it's a joke")
      ]
    end

    it 'renders a template, according to the requested format' do
      view     = Articles::Index
      rendered = view.render({ format: :html }, { articles: @articles })

      rendered.must_include "<h1>Alien Invasion!</h1>"
      rendered.must_include "<h1>No, it's a joke</h1>"
    end

    it 'delegates to subclasses, when they explicitely handle the format' do
      view     = Articles::Index
      rendered = view.render({ format: :atom }, { articles: @articles })

      rendered.must_include "<title>Alien Invasion!</title>"
      rendered.must_include "<title>No, it's a joke</title>"
    end

    it "returns nil when the requested format can't be handled because the template is missing" do
      view     = Articles::Index
      rendered = view.render({ format: :js }, { articles: @articles })

      rendered.must_be_nil
    end

    it 'renders a template, including the current view as a context' do
      view     = Articles::Show
      rendered = view.render({ format: :html }, { article: @articles.first })

      rendered.must_include "<h1>ALIEN INVASION!</h1>"
    end

    it 'can safely cache local vars' do
      @articles.each do |article|
        view     = Articles::Show
        rendered = view.render({ format: :html }, { article: article })

        rendered.must_include "<h1>#{ article.title.upcase }</h1>"
      end
    end

    it 'implicit inheriths variables from locals' do
      view     = Articles::Show
      rendered = view.render({ format: :json }, { article: @articles.last })

      rendered.must_include %(title: "ekoj a s'ti ,on")
    end
  end
end
