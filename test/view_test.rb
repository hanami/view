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

      class ConfigurationChildView < ConfigurationView
      end

      class ConfigurationLayout
        include Lotus::Layout
      end
    end

    after do
      Object.send(:remove_const, :ConfigurationChildView)
      Object.send(:remove_const, :ConfigurationView)
      Object.send(:remove_const, :ConfigurationLayout)
    end

    it 'exposes class configuration' do
      Lotus::View.configuration.must_be_kind_of(Lotus::View::Configuration)
    end

    it 'defaults root to the current dir' do
      Lotus::View.configuration.root.must_equal(Pathname.new('.').realpath)
    end

    it 'a view inheriths the configuration from the framework' do
      expected = Lotus::View.configuration
      actual   = ConfigurationView.configuration

      actual.must_equal(expected)
    end

    it 'a view inheriths the parent' do
      parent = ConfigurationView.configuration
      child  = ConfigurationChildView.configuration

      child.must_equal(parent)
      child.wont_be_same_as(parent)
    end

    it "doesn't interfer with parent configuration" do
      parent = AppView.configuration
      child  = AppViewRoot.configuration

      child.root.wont_equal(parent.root)

      child.wont_equal(parent)
      child.wont_be_same_as(parent)
    end

    it 'a view must be included in the framework configuration registry' do
      Lotus::View.configuration.views.must_include(ConfigurationView)
      ConfigurationView.configuration.views.wont_include(ConfigurationView)
    end

    it 'a layout inheriths the configuration from the framework' do
      expected = Lotus::View.configuration
      actual   = ConfigurationLayout.configuration

      actual.must_equal(expected)
    end

    it 'a layout must be included in the framework configuration registry' do
      Lotus::View.configuration.layouts.must_include(ConfigurationLayout)
      ConfigurationLayout.configuration.layouts.wont_include(ConfigurationView)
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

  describe '.duplicate' do
    before do
      Lotus::View.class_eval do
        configure do
          root '..'
        end
      end

      DuplicatedView = Lotus::View.duplicate

      @framework_config  = Lotus::View.configuration
      @duplicated_config = DuplicatedView.configuration
    end

    after do
      Object.send(:remove_const, :DuplicatedView)
    end

    it 'creates a copy of self' do
      @duplicated_config.root.must_equal(@framework_config.root)
    end

    it 'creates a copy of self' do
      @duplicated_config.root('.')

      @duplicated_config.root.must_equal Pathname.new('.').realpath
      @framework_config.root.must_equal  Pathname.new('..').realpath
    end
  end

  describe 'global layout' do
    before do
      Lotus::View.class_eval do
        configure do
          layout :application
        end
      end

      class ViewWithInheritedLayout
        include Lotus::View
      end
    end

    after do
      Object.send(:remove_const, :ViewWithInheritedLayout)
    end

    it 'sets global layout' do
      ViewWithInheritedLayout.layout.must_equal ApplicationLayout
    end
  end
end
