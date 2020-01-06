# frozen_string_literal: true

module Views
  module Articles
    class Show < ApplicationView
      config.template = "articles/show"

      expose :article
    end
  end
end
