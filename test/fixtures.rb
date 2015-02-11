require 'json'

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

  def names
    location_names
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

  def escaped_location_names
    @object.location_names
  end

  def raw_location_names
    _raw @object.location_names
  end

  def inspect_object
    _raw @object.inspect
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
      _raw SongWidget.new(song).render
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

module MyCustomModule
end

module MyOtherCustomModule
end

module CardDeck
  View = Lotus::View.duplicate(self) do
    namespace CardDeck
    root __dir__ + '/fixtures/templates/card_deck/app/templates'
    layout :application
    prepare do
      include MyCustomModule
      include MyOtherCustomModule
    end
  end

  class ApplicationLayout
    include CardDeck::Layout
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

module Store
  View = Lotus::View.duplicate(self)
  View.extend Unloadable

  module Helpers
    module AssetTagHelpers
      def javascript_tag(source)
        %(<script type="text/javascript" src="/javascripts/#{ source }.js" />)
      end
    end
  end

  module Views
    class StoreLayout
      include Store::Layout
      include Store::Helpers::AssetTagHelpers
    end

    module Home
      class Index
        include Store::View
        template 'store/templates/home/index'
        layout :store
      end

      class JsonIndex < Index
        format :json
      end
    end
  end
end

Store::View.load!

User = Struct.new(:username)
Book = Struct.new(:title)

class UserXmlSerializer
  def initialize(user)
    @user = user
  end

  def serialize
    @user.to_h.map do |attr, value|
      %(<#{ attr }>#{ value }</#{ attr }>)
    end.join("\n")
  end
end

class UserLayout
  include Lotus::Layout

  def page_title(username)
    "User: #{ username }"
  end
end

module Users
  class Show
    include Lotus::View
    layout :user

    def custom
      %(<script>alert('custom')</script>)
    end

    def username
      user.username
    end

    def raw_username
      _raw user.username
    end

    def book
      _escape(locals[:book])
    end
  end

  class XmlShow < Show
    format :xml

    def render
      UserXmlSerializer.new(user).serialize
    end
  end

  class JsonShow < Show
    format :json

    def render
      _raw JSON.generate(user.to_h)
    end
  end

  class Extra
    include Lotus::View

    def username
      user.username
    end
  end
end
