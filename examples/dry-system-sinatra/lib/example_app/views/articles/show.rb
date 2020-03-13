# frozen_string_literal: true

require "example_app/import"
require "example_app/view"

module ExampleApp
  module Views
    module Articles
      class Show < View
        include Import["article_repo"]

        config.template = "articles/show"

        expose :article do |slug:|
          article_repo.by_slug!(slug)
        end
      end
    end
  end
end
