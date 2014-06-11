require 'test_helper'

describe Lotus::View::Configuration do
  before do
    @configuration = Lotus::View::Configuration.new
  end

  describe '#root' do
    describe 'when a value is given' do
      describe "and it's a string" do
        it 'sets it as a Pathname' do
          @configuration.root 'test'
          @configuration.root.must_equal(Pathname.new('test').realpath)
        end
      end

      describe "and it's a pathname" do
        it 'sets it' do
          @configuration.root Pathname.new('test')
          @configuration.root.must_equal(Pathname.new('test').realpath)
        end
      end

      describe "and it implements #to_pathname" do
        before do
          RootPath = Struct.new(:path) do
            def to_pathname
              Pathname(path)
            end
          end
        end

        after do
          Object.send(:remove_const, :RootPath)
        end

        it 'sets the converted value' do
          @configuration.root RootPath.new('test')
          @configuration.root.must_equal(Pathname.new('test').realpath)
        end
      end

      describe "and it's an unexisting path" do
        it 'raises an error' do
          -> {
            @configuration.root '/path/to/unknown'
          }.must_raise(Errno::ENOENT)
        end
      end
    end

    describe "when a value isn't given" do
      it 'defaults to the current path' do
        @configuration.root.must_equal(Pathname.new('.').realpath)
      end
    end
  end

  describe '#load_paths' do
    before do
      @configuration.root '.'
    end

    describe 'by default' do
      it "it's equal to root" do
        @configuration.load_paths.must_include @configuration.root
      end
    end

    it 'allows to add other paths' do
      @configuration.load_paths << '..'
      @configuration.load_paths.must_include '..'
    end
  end

  describe '#layout' do
    describe "when a value is given" do
      it 'loads the corresponding class' do
        @configuration.layout :application
        @configuration.layout.must_equal ApplicationLayout
      end
    end

    describe "when a value isn't given" do
      it 'defaults to the null layout' do
        @configuration.layout.must_equal(Lotus::View::Rendering::NullLayout)
      end
    end

    describe "when the class wasn't loaded yet" do
      before do
        @configuration.layout :lazy

        class LazyLayout
          include Lotus::Layout
        end
      end

      after do
        Object.send(:remove_const, :LazyLayout)
      end

      it 'lazily loads the layout' do
        @configuration.layout.must_equal(LazyLayout)
      end
    end
  end

  describe '#views' do
    it 'defaults to an empty set' do
      @configuration.views.must_be_empty
    end

    it 'allows to add views' do
      @configuration.add_view(HelloWorldView)
      @configuration.views.must_include(HelloWorldView)
    end

    it 'eliminates duplications' do
      @configuration.add_view(RenderView)
      @configuration.add_view(RenderView)

      @configuration.views.size.must_equal(1)
    end
  end

  describe '#layouts' do
    it 'defaults to an empty set' do
      @configuration.layouts.must_be_empty
    end

    it 'allows to add layouts' do
      @configuration.add_layout(ApplicationLayout)
      @configuration.layouts.must_include(ApplicationLayout)
    end

    it 'eliminates duplications' do
      @configuration.add_layout(GlobalLayout)
      @configuration.add_layout(GlobalLayout)

      @configuration.layouts.size.must_equal(1)
    end
  end

  describe 'duplicate' do
    before do
      @configuration.root 'test'
      @configuration.load_paths << '..'
      @configuration.layout :application
      @configuration.add_view(HelloWorldView)
      @configuration.add_layout(ApplicationLayout)

      @config = @configuration.duplicate
    end

    it 'returns a copy of the configuration' do
      @config.root.must_equal       @configuration.root
      @config.load_paths.must_equal @configuration.load_paths
      @config.layout.must_equal     @configuration.layout
      @config.views.must_be_empty
      @config.layouts.must_be_empty
    end

    it "doesn't affect the original configuration" do
      @config.root '.'
      @config.load_paths << '../..'
      @config.layout :global
      @config.add_view(RenderView)
      @config.add_layout(GlobalLayout)

      @config.root.must_equal         Pathname.new('.').realpath

      @config.load_paths.must_include @config.root
      @config.load_paths.must_include '..'
      @config.load_paths.must_include '../..'

      @config.layout.must_equal       GlobalLayout
      @config.views.must_include      RenderView
      @config.layouts.must_include    GlobalLayout

      @configuration.root.must_equal       Pathname.new('test').realpath

      @configuration.load_paths.must_include @config.root
      @configuration.load_paths.must_include '..'
      @configuration.load_paths.wont_include '../..'

      @configuration.layout.must_equal     ApplicationLayout

      @configuration.views.must_include    HelloWorldView
      @configuration.views.wont_include    RenderView

      @configuration.layouts.must_include  ApplicationLayout
      @configuration.layouts.wont_include  GlobalLayout
    end

    it 'duplicates namespace' do
      @configuration.namespace(CardDeck)
      conf = @configuration.duplicate

      conf.namespace.must_equal(CardDeck)
    end

    describe 'layout lazy loading' do
      before do
        Lotus::View.configure do
          layout :application
        end

        module LazyApp
          View = Lotus::View.generate(self)

          module Views
            module Dashboard
              class Index
                include LazyApp::View
              end
            end

            class ApplicationLayout
              include LazyApp::Layout
            end
          end
        end
      end

      after do
        Lotus::View.configuration.reset!
        Object.send(:remove_const, :LazyApp)
      end

      it 'lazily loads the layout' do
        expected = LazyApp::Views::ApplicationLayout
        expected.template.must_equal 'application'

        LazyApp::Views::Dashboard::Index.layout.must_equal               expected
        LazyApp::Views::Dashboard::Index.configuration.layout.must_equal expected
      end
    end
  end

  describe '#load!' do
    before do
      class MockLayout
        def self.loaded?
          @loaded
        end

        protected
        def self.load!
          @loaded = true
        end
      end

      class MockView < MockLayout
      end

      @configuration.add_view(MockView)
      @configuration.add_layout(MockLayout)

      @configuration.load!
    end

    after do
      Object.send(:remove_const, :MockLayout)
      Object.send(:remove_const, :MockView)
    end

    it 'loads the views' do
      MockView.must_be :loaded?
    end

    it 'loads the layouts' do
      MockLayout.must_be :loaded?
    end
  end

  describe '#reset!' do
    before do
      @configuration.root 'test'
      @configuration.load_paths << '..'
      @configuration.layout :application
      @configuration.add_view(HelloWorldView)
      @configuration.add_layout(ApplicationLayout)

      @configuration.reset!
    end

    it 'resets root' do
      root = Pathname.new('.').realpath

      @configuration.root.must_equal         root
      @configuration.load_paths.must_include root
      @configuration.layout.must_equal Lotus::View::Rendering::NullLayout
      @configuration.views.must_be_empty
      @configuration.layouts.must_be_empty
    end

    it "doesn't reset namespace" do
      @configuration.namespace(CardDeck)
      @configuration.reset!

      @configuration.namespace.must_equal(CardDeck)
    end
  end
end
