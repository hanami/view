class HelloWorldView
  include Lotus::View
end

class RenderView
  include Lotus::View
end

class JsonRenderView
  include Lotus::View
  format :json
end

class AppView
  include Lotus::View
  root __dir__ + '/fixtures/templates/app'
end

class MissingTemplateView
  include Lotus::View
end

module App
  class View
    include Lotus::View
  end
end

module Articles
  class Index
    include Lotus::View
  end

  class RssIndex < Index
    format :rss
  end

  class AtomIndex < RssIndex
    format :atom
  end

  class New
    include Lotus::View

    def errors
      {}
    end
  end

  class AlternativeNew
    include Lotus::View
  end

  class Create
    include Lotus::View
    template 'articles/new'

    def errors
      {title: 'Title is required'}
    end
  end

  class Show
    include Lotus::View

    def title
      @title ||= article.title.upcase
    end
  end

  class JsonShow < Show
    format :json

    def article
      OpenStruct.new(title: super.title.reverse)
    end

    def title
      super.downcase
    end
  end
end
