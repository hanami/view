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
  class View
    include Lotus::View
    abstract!
  end

  class Index < View
  end

  class RssIndex < Index
    format :rss
  end

  class AtomIndex < RssIndex
    format :atom
  end
end
