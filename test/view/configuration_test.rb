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
        @configuration.load_paths.must_equal [@configuration.root]
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

      @configuration.root.must_equal        root
      @configuration.load_paths.must_equal [root]
      @configuration.layout.must_equal Lotus::View::Rendering::NullLayout
      @configuration.views.must_be_empty
      @configuration.layouts.must_be_empty
    end
  end
end
