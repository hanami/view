# frozen_string_literal: true

require "ostruct"

module ExampleApp
  Article = Struct.new(:slug, :title)

  class ArticleRepo
    ARTICLES = [
      {slug: "together-breakfast", title: "Together Breakfast"},
      {slug: "cat-fingers", title: "Cat Fingers"}
    ].freeze

    def by_slug!(slug)
      if (article = ARTICLES.detect { |a| a[:slug] == slug })
        Article.new(*article.values)
      else
        raise "Article with slug +#{slug}+ not found"
      end
    end

    def listing
      ARTICLES.map { |a| Article.new(*a.values) }
    end
  end
end
