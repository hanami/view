# frozen_string_literal: true

require "sinatra/base"
require "byebug"

module ExampleApp
  class Web < Sinatra::Base
    get "/" do
      redirect "/articles"
    end

    get "/articles" do
      render_view "articles.index"
    end

    get "/articles/:slug" do |slug|
      render_view "articles.show", slug: slug
    end

    helpers do
      def render_view(identifier, with: {}, **input)
        container["views.#{identifier}"].(
          context: view_context(**with),
          **input
        ).to_s
      end

      def view_context(**options)
        container["view.context"].with(view_context_options(**options))
      end

      def view_context_options(**overrides)
        {
          request: request
        }.merge(overrides)
      end

      def container
        ExampleApp::Container
      end
    end
  end
end
