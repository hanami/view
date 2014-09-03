class HelloWorldView
  include Lotus::View
end

class RenderView
  include Lotus::View
end

class RenderViewMethodOverride
  include Lotus::View

  def select
    'foo'
  end
end

class RenderViewMethodWithArgs
  include Lotus::View

  def planet(name)
    name.to_s
  end
end

class RenderViewMethodWithBlock
  include Lotus::View

  def each_thing
    yield 'thing 1'
    yield 'thing 2'
    yield 'thing 3'
  end
end

class JsonRenderView
  include Lotus::View
  format :json
end

class AppView
  include Lotus::View
  root __dir__ + '/fixtures/templates/app'
  layout :application
end

class AppViewLayout < AppView
  layout nil
end

class AppViewRoot < AppView
  root '.'
end

class NestedView
  include Lotus::View
  root __dir__ + '/fixtures/templates'
end

class MissingTemplateView
  include Lotus::View
end

module App
  class View
    include Lotus::View
  end
end

class ApplicationLayout
  include Lotus::Layout

  def title
    'Title:'
  end
end

class GlobalLayout
end

module Articles
  class Index
    include Lotus::View
    layout :application

    def title
      "#{ layout.title } articles"
    end
  end

  class RssIndex < Index
    format :rss
    layout nil
  end

  class AtomIndex < RssIndex
    format :atom
    layout nil
  end

  class New
    include Lotus::View

    def errors
      {}
    end
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
      OpenStruct.new(title: locals[:article].title.reverse)
    end

    def title
      super.downcase
    end
  end
end

class Map
  attr_reader :locations

  def initialize(locations)
    @locations = locations
  end

  def location_names
    @locations.join(', ')
  end
end

class MapPresenter
  include Lotus::Presenter

  def count
    locations.count
  end

  def location_names
    super.upcase
  end

  def inspect_object
    @object.inspect
  end
end

module Dashboard
  class Index
    include Lotus::View

    def map
      MapPresenter.new(locals[:map])
    end
  end
end

class IndexView
  include Lotus::View
  layout :application
end

class SongWidget
  attr_reader :song

  def initialize(song)
    @song = song
  end

  def render
    %(<audio src="#{ song.url }">#{ song.title }</audio>)
  end
end

module Songs
  class Show
    include Lotus::View
    format :html

    def render
      SongWidget.new(song).render
    end
  end
end

module Metrics
  class Index
    include Lotus::View

    def render
      %(metrics)
    end
  end
end

module Contacts
  class Show
    include Lotus::View
  end
end

module Nodes
  class Parent
    include Lotus::View
  end
end

module CardDeck
  View = Lotus::View.duplicate(self) do
    namespace CardDeck
    root __dir__ + '/fixtures/templates/card_deck/app/templates'
    layout :application
  end

  class ApplicationLayout
    include Lotus::Layout
  end

  class StandaloneView
    include CardDeck::View
  end

  module Views
    class Standalone
      include CardDeck::View
    end

    module Home
      class Index
        include CardDeck::View
      end

      class JsonIndex < Index
        format :json
        layout nil
      end
    end
  end
end

class LayoutForScopeTest
  def foo
    'x'
  end
end

class ViewForScopeTest
  def bar
    'y'
  end
end
