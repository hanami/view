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

  describe '#reset!' do
    before do
      @configuration.root 'test'
      @configuration.reset!
    end

    it 'resets root' do
      @configuration.root.must_equal Pathname.new('.').realpath
    end
  end
end
