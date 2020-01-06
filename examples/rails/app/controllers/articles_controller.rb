# frozen_string_literal: true

class ArticlesController < ApplicationController
  def index
    articles = Article.all

    render html: Views::Articles::Index.new.(articles: articles).to_s.html_safe
  end

  def show
    article = Article.find(params[:id])

    render html: Views::Articles::Show.new.(article: article).to_s.html_safe
  end
end
