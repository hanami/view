require 'test_helper'

describe Lotus::View do
  before do
    Lotus::View.unload!
    Lotus::View.configuration.reset!
  end

  describe '.configuration' do
    before do
      class ConfigurationView
        include Lotus::View
      end
    end

    after do
      Object.send(:remove_const, :ConfigurationView)
    end

    it 'exposes class configuration' do
      Lotus::View.configuration.must_be_kind_of(Lotus::View::Configuration)
    end

    it 'defaults root to the current dir' do
      Lotus::View.configuration.root.must_equal(Pathname.new('.').realpath)
    end

    it 'inheriths the configuration from the framework' do
      expected = Lotus::View.configuration
      actual   = ConfigurationView.configuration

      actual.must_equal(expected)
    end
  end

  describe '.configure' do
    it 'allows to configure the framework' do
      path = Pathname.new('.').join('test/fixtures').realpath

      Lotus::View.class_eval do
        configure do
          root path
        end
      end

      Lotus::View.configuration.root.must_equal(path)
    end

    it 'allows to override one value' do
      Lotus::View.class_eval do
        configure do
          load_paths << 'test/fixtures'
        end

        configure do
          load_paths << 'test/fixtures/templates'
        end
      end

      configuration = Lotus::View.configuration
      configuration.load_paths.must_include('test/fixtures')
      configuration.load_paths.must_include('test/fixtures/templates')
    end
  end

  describe '.layout=' do
    before do
      Lotus::View.unload!

      class ViewWithInheritedLayout
        include Lotus::View
      end

      Lotus::View.layout = :application
      Lotus::View.load!
    end

    after do
      Lotus::View.unload!
      Object.send(:remove_const, :ViewWithInheritedLayout)
      Lotus::View.layout = nil
      Lotus::View.load!
    end

    it 'sets global layout' do
      ViewWithInheritedLayout.layout.must_equal ApplicationLayout
    end
  end
end
