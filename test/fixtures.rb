class RenderView
  include Lotus::View
end

class ConfigRenderView
  include Lotus::View
end

class HamlRenderView
  include Lotus::View
  self.engine = :haml
end

class AppView
  include Lotus::View
  self.root = __dir__ + '/fixtures/templates/app'
end

class MissingTemplateView
  include Lotus::View
end

module App
  class View
    include Lotus::View
  end
end
