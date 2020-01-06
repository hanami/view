# frozen_string_literal: true

module Views
  module Articles
    class Index < ApplicationView
      config.template = "articles/index"

      expose :articles
    end
  end
end
