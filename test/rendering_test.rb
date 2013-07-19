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
  end
end
