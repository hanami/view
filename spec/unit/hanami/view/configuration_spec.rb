# frozen_string_literal: true

RSpec.describe Hanami::View::Configuration do
  before do
    Hanami::View.unload!
    @configuration = Hanami::View::Configuration.new
  end

  describe "#root" do
    describe "when a value is given" do
      describe "and it's a string" do
        it "sets it as a Pathname" do
          @configuration.root "spec"
          expect(@configuration.root).to eq Pathname.new("spec").realpath
        end
      end

      describe "and it's a pathname" do
        it "sets it" do
          @configuration.root Pathname.new("spec")
          expect(@configuration.root).to eq Pathname.new("spec").realpath
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

        it "sets the converted value" do
          @configuration.root RootPath.new("spec")
          expect(@configuration.root).to eq Pathname.new("spec").realpath
        end
      end

      describe "and it's an unexisting path" do
        it "raises an error" do
          expect do
            @configuration.root "/path/to/unknown"
          end.to raise_error(Errno::ENOENT)
        end
      end
    end

    describe "when a value isn't given" do
      it "defaults to the current path" do
        expect(@configuration.root).to eq Pathname.new(".").realpath
      end
    end
  end

  describe "#load_paths" do
    before do
      @configuration.root "."
    end

    describe "by default" do
      it "it's equal to root" do
        expect(@configuration.load_paths).to include @configuration.root
      end
    end

    it "allows to add other paths" do
      @configuration.load_paths << ".."
      expect(@configuration.load_paths).to include ".."
    end
  end

  describe "#layout" do
    describe "when a value is given" do
      it "loads the corresponding class" do
        @configuration.layout :application
        expect(@configuration.layout).to eq ApplicationLayout
      end
    end

    describe "when a value isn't given" do
      it "defaults to the null layout" do
        expect(@configuration.layout).to eq Hanami::View::Rendering::NullLayout
      end
    end

    describe "when the class wasn't loaded yet" do
      before do
        @configuration.layout :lazy

        class LazyLayout
          include Hanami::Layout
        end
      end

      after do
        Object.send(:remove_const, :LazyLayout)
      end

      it "lazily loads the layout" do
        expect(@configuration.layout).to eq LazyLayout
      end
    end
  end

  describe "#views" do
    it "defaults to an empty set" do
      expect(@configuration.views).to be_empty
    end

    it "allows to add views" do
      @configuration.add_view(HelloWorldView)
      expect(@configuration.views).to include(HelloWorldView)
    end

    it "eliminates duplications" do
      @configuration.add_view(RenderView)
      @configuration.add_view(RenderView)

      expect(@configuration.views.size).to eq(1)
    end
  end

  describe "#layouts" do
    it "defaults to an empty set" do
      expect(@configuration.layouts).to be_empty
    end

    it "allows to add layouts" do
      @configuration.add_layout(ApplicationLayout)
      expect(@configuration.layouts).to include(ApplicationLayout)
    end

    it "eliminates duplications" do
      @configuration.add_layout(GlobalLayout)
      @configuration.add_layout(GlobalLayout)

      expect(@configuration.layouts.size).to eq(1)
    end
  end

  describe "#partials" do
    before do
      @template_stub = OpenStruct.new()
    end

    it "defaults to an empty set" do
      expect(@configuration.partials).to be_empty
    end

    it "allows to add partials" do
      @configuration.add_partial(Hanami::View::Rendering::PartialFile.new("shared/_foo", "json", @template_stub))
      expect(@configuration.partials.keys).to include("shared/_foo")
      expect(@configuration.partials["shared/_foo"]).to eq(json: @template_stub)
    end

    it "eliminates duplications" do
      @configuration.add_partial(Hanami::View::Rendering::PartialFile.new("shared/_foo", "json", @template_stub))
      @configuration.add_partial(Hanami::View::Rendering::PartialFile.new("shared/_foo", "json", @template_stub))

      expect(@configuration.partials.size).to eq(1)
    end
  end

  describe "#default_encoding" do
    it "defaults to Encoding::UTF_8" do
      expect(@configuration.default_encoding).to eq Encoding::UTF_8
    end

    it "allows to set different value" do
      encoding = Encoding.list.sample
      @configuration.default_encoding encoding.to_s
      expect(@configuration.default_encoding).to eq encoding
    end

    it "raises error in case of unknown encoding" do
      expect do
        @configuration.default_encoding "abc"
      end.to raise_error(ArgumentError, "unknown encoding name - abc")
    end
  end

  describe "#prepare" do
    before do
      module FooRendering
        def render
          "foo"
        end
      end

      class PrepareView
      end
    end

    after do
      Object.__send__(:remove_const, :FooRendering)
      Object.__send__(:remove_const, :PrepareView)
    end

    it "allows to set a code block to be yielded when Hanami::View is included" do
      Hanami::View.configure do
        prepare do
          include FooRendering
        end
      end

      PrepareView.__send__(:include, Hanami::View)
      expect(PrepareView.render(format: :html)).to eq "foo"
    end

    it "raises error in case of missing block" do
      expect do
        @configuration.prepare
      end.to raise_error(ArgumentError, "Please provide a block")
    end
  end

  describe "#duplicate" do
    before do
      @configuration.root "spec"
      @configuration.load_paths << ".."
      @configuration.layout :application
      @configuration.default_encoding "UTF-7"
      @configuration.add_view(HelloWorldView)
      @configuration.add_layout(ApplicationLayout)
      @configuration.add_partial(Hanami::View::Rendering::PartialFile.new("shared/_foo", "json", Object.new))
      @configuration.prepare { include Kernel }

      @config = @configuration.duplicate
    end

    it "returns a copy of the configuration" do
      expect(@config.root).to eq             @configuration.root
      expect(@config.load_paths).to eq       @configuration.load_paths
      expect(@config.layout).to eq           @configuration.layout
      expect(@config.default_encoding).to eq @configuration.default_encoding
      expect(@config.modules).to eq          @configuration.modules
      expect(@config.views).to be_empty
      expect(@config.layouts).to be_empty
      expect(@config.partials).to be_empty
    end

    it "doesn't affect the original configuration" do
      @config.root "."
      @config.load_paths << "../.."
      @config.layout :global
      @config.default_encoding "iso-8859-1"
      @config.add_view(RenderView)
      @config.add_layout(GlobalLayout)
      @config.add_partial(Hanami::View::Rendering::PartialFile.new("shared/_bar", "html", Object.new))
      @config.prepare { include Comparable }

      expect(@config.root).to eq                            Pathname.new(".").realpath

      expect(@config.load_paths).to include                 @config.root
      expect(@config.load_paths).to include                 ".."
      expect(@config.load_paths).to include                 "../.."

      expect(@config.layout).to eq                          GlobalLayout
      expect(@config.views).to include                      RenderView
      expect(@config.layouts).to include                    GlobalLayout
      expect(@config.partials.keys).to include              "shared/_bar"
      expect(@config.modules.size).to eq                    2

      expect(@configuration.root).to eq                     Pathname.new("spec").realpath

      expect(@configuration.load_paths).to include          @config.root
      expect(@configuration.load_paths).to include          ".."
      expect(@configuration.load_paths).to_not include      "../.."

      expect(@configuration.default_encoding).to eq         Encoding::UTF_7

      expect(@configuration.layout).to eq                   ApplicationLayout

      expect(@configuration.views).to include               HelloWorldView
      expect(@configuration.views).to_not include           RenderView

      expect(@configuration.layouts).to include             ApplicationLayout
      expect(@configuration.layouts).to_not include         GlobalLayout

      expect(@configuration.partials.keys).to include       "shared/_foo"
      expect(@configuration.partials.keys).to_not include   "shared/_bar"
    end

    it "duplicates namespace" do
      @configuration.namespace(CardDeck)
      conf = @configuration.duplicate

      expect(conf.namespace).to eq(CardDeck)
    end

    describe "layout lazy loading" do
      before do
        Hanami::View.configure do
          layout :application
        end

        module LazyApp
          View = Hanami::View.duplicate(self)

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
        Object.send(:remove_const, :LazyApp)
      end

      it "lazily loads the layout" do
        expected = LazyApp::Views::ApplicationLayout
        expect(expected.template).to eq "application"

        expect(LazyApp::Views::Dashboard::Index.layout).to eq               expected
        expect(LazyApp::Views::Dashboard::Index.configuration.layout).to eq expected
      end
    end
  end

  describe "#load!" do
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

    it "loads the views" do
      expect(MockView).to be_loaded
    end

    it "loads the layouts" do
      expect(MockLayout).to be_loaded
    end

    it "loads the partials" do
      expect(@configuration.partials).to_not be_empty
    end
  end

  describe "#reset!" do
    before do
      @configuration.root "spec"
      @configuration.load_paths << ".."
      @configuration.layout :application
      @configuration.default_encoding "Windows-1253"
      @configuration.add_view(HelloWorldView)
      @configuration.add_layout(ApplicationLayout)
      @configuration.add_partial(Hanami::View::Rendering::PartialFile.new("shared/_foo", "html", Object.new))

      @configuration.reset!
    end

    it "resets root" do
      root = Pathname.new(".").realpath

      expect(@configuration.root).to eq root

      expect(@configuration.load_paths).to include root
      expect(@configuration.layout).to eq Hanami::View::Rendering::NullLayout
      @configuration.default_encoding        "utf-8"
      expect(@configuration.views).to be_empty
      expect(@configuration.layouts).to be_empty
      expect(@configuration.partials).to be_empty
    end

    it "doesn't reset namespace" do
      @configuration.namespace(CardDeck)
      @configuration.reset!

      expect(@configuration.namespace).to eq(CardDeck)
    end
  end
end
