# frozen_string_literal: true

require "example_app/import"
require "example_app/view"

module ExampleApp
  module Views
    module Articles
      class Index < View
        include Import["article_repo"]

        config.template = "articles/index"

        expose :articles do
          article_repo.listing
        end
      end
    end
  end
end
