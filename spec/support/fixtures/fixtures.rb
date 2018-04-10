require 'json'

class HelloWorldView
  include Hanami::View
end

class DisabledLayoutView
  include Hanami::View
  layout false
end

class RenderView
  include Hanami::View
end

class RenderViewMethodOverride
  include Hanami::View

  def select
    'foo'
  end
end

class RenderViewMethodWithArgs
  include Hanami::View

  def planet(name)
    name.to_s
  end
end

class RenderViewMethodWithBlock
  include Hanami::View

  def each_thing
    yield 'thing 1'
    yield 'thing 2'
    yield 'thing 3'
  end
end

class RenderViewWithMissingPartialTemplate
  include Hanami::View
end

class EncodingView
  include Hanami::View
end

class JsonRenderView
  include Hanami::View
  format :json
end

class AppView
  include Hanami::View
  root __dir__ + '/templates/app'
  layout :application
end

class AppViewLayout < AppView
  layout false
end

class AppViewRoot < AppView
  root '.'
end

class NestedView
  include Hanami::View
  root __dir__ + '/templates'
end


module Organisations
  class Action
    include Hanami::View
    root __dir__ + '/templates'
  end

  module OrderTemplates
    class Action
      include Hanami::View
      root __dir__ + '/templates'
    end
  end
end

class MissingTemplateView
  include Hanami::View
end

module App
  class View
    include Hanami::View
  end
end

class ApplicationLayout
  include Hanami::Layout

  def title
    'Title:'
  end
end

class ContactsLayout
  include Hanami::Layout
end

class GlobalLayout
end

module Members
  module Articles
    class Index
      include Hanami::View
      layout :application

      def title
        "#{ layout.title } articles"
      end
    end
  end
end

module Articles
  class Index
    include Hanami::View
    layout :application

    def title
      "#{ layout.title } articles"
    end
  end

  class RssIndex < Index
    format :rss
    layout false
  end

  class AtomIndex < RssIndex
    format :atom
    layout false
  end

  class New
    include Hanami::View

    def errors
      local(:result).errors
    end
  end

  class Create
    include Hanami::View
    template 'articles/new'

    def errors
      result.errors
    end
  end

  class Show
    include Hanami::View

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
  include Hanami::Presenter

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
    include Hanami::View

    def map
      MapPresenter.new(locals[:map])
    end
  end
end

class IndexView
  include Hanami::View

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
    include Hanami::View
    format :html

    def render
      _raw SongWidget.new(song).render
    end
  end
end

module Metrics
  class Index
    include Hanami::View

    def render
      %(metrics)
    end
  end
end

module Contacts
  class Show
    include Hanami::View
    include Helpers::AssetTagHelpers

    layout :contacts
  end
end

module Desks
  class Show
    include Hanami::View
    include Helpers::AssetTagHelpers
  end
end

module Nodes
  class Parent
    include Hanami::View
  end
end

module MyCustomModule
end

module MyOtherCustomModule
end

module CardDeck
  View = Hanami::View.duplicate(self) do
    namespace CardDeck
    root __dir__ + '/templates/card_deck/app/templates'
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
        layout false
      end

      class RssIndex < Index
        format :rss
        layout false
      end
    end
  end
end

class BrokenLogic
  def run
    raise ArgumentError.new('nope')
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

  def wrong_reference
    unknown_method
  end

  def wrong_method
    "string".unknown
  end

  def raise_error
    BrokenLogic.new.run
  end
end

module App1
  View = Hanami::View.duplicate(self) do
    root __dir__ + '/templates/app1/templates'
  end

  module Views
    module Home
      class Index
        include App1::View
      end
    end
  end
end

App1::View.load!

module App2
  View = Hanami::View.duplicate(self) do
    root __dir__ + '/templates/app2/templates'
  end

  module Views
    module Home
      class Index
        include App2::View
      end

      class Show
        include App2::View
      end
    end
  end
end

App2::View.load!

module Store
  View = Hanami::View.duplicate(self)
  View.extend Unloadable

  Helpers = ::Helpers

  module Views
    class StoreLayout
      include Store::Layout
      include Store::Helpers::AssetTagHelpers

      def head
        Hanami::Utils::Escape::SafeString.new %(<meta name="hanamirb-version" content="0.3.1">)
      end

      def user_name
        "Joe Blogs"
      end

      def render_flash
        return if local(:flash).nil?

        local(:flash).map do |type, message|
          %(<div class="flash-#{type}">#{message}</div>)
        end.join("\n")
      end
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

    module Products
      class Show
        include Store::View
        layout :store

        def footer
          _raw %(<script src="/javascripts/product-tracking.js"></script>)
        end
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
  include Hanami::Layout

  def page_title(username)
    "User: #{ username }"
  end
end

module Users
  class Show
    include Hanami::View
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

    protected

    def protected_username
      user.username
    end

    private
    def private_username
      user.username
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
    include Hanami::View

    def username
      user.username
    end
  end
end

module DeepPartials
  View = Hanami::View.duplicate(self) do
    root __dir__ + '/templates/deep_partials/templates'
  end

  class BooksCollection
    undef :initialize_dup
  end

  module Views
    module Home
      class Index
        include DeepPartials::View

        def books
          BooksCollection.new
        end
      end
    end
  end
end

DeepPartials::View.load!


module App3
  View = Hanami::View.duplicate(self) do
    root __dir__ + '/templates/app3/templates'
  end

  module Views
    module Home
      class Index
        include App3::View

        def name
          "View #{locals[:name]}"
        end
      end
    end
  end
end

App3::View.load!


module PartialAndLayout
  View = Hanami::View.duplicate(self) do
    root __dir__ + '/templates/partial_and_layout/templates'
  end

  module Views
    class MainLayout
      include PartialAndLayout::Layout
    end

    class SecondLayout
      include PartialAndLayout::Layout

      def name
        "Layout Hanami"
      end
    end

    class ThirdLayout
      include PartialAndLayout::Layout
    end

    module Home
      class Index
        include PartialAndLayout::View
        layout :main

        def name
          "Presented #{locals[:name]}"
        end
      end

      class Show
        include PartialAndLayout::View
        layout :second
      end

      class New
        include PartialAndLayout::View
        layout :third
      end
    end
  end
end

PartialAndLayout::View.load!
