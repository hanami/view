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
