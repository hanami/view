require 'test_helper'

describe Hanami::View do
  before do
    Hanami::View.unload!
  end

  describe '.configuration' do
    before do
      class ConfigurationView
        include Hanami::View
      end

      class ConfigurationChildView < ConfigurationView
      end

      class ConfigurationLayout
        include Hanami::Layout
      end
    end

    after do
      Object.send(:remove_const, :ConfigurationChildView)
      Object.send(:remove_const, :ConfigurationView)
      Object.send(:remove_const, :ConfigurationLayout)
    end

    it 'exposes class configuration' do
      Hanami::View.configuration.must_be_kind_of(Hanami::View::Configuration)
    end

    it 'defaults root to the current dir' do
      Hanami::View.configuration.root.must_equal(Pathname.new('.').realpath)
    end

    it 'a view inheriths the configuration from the framework' do
      expected = Hanami::View.configuration
      actual   = ConfigurationView.configuration

      actual.must_equal(expected)
    end

    it 'a view inheriths the parent' do
      parent = ConfigurationView.configuration
      child  = ConfigurationChildView.configuration

      child.must_equal(parent)
      child.wont_be_same_as(parent)
    end

    it "doesn't mutate configuration" do
      parent = AppView.configuration
      child  = AppViewRoot.configuration

      child.must_equal(parent)
    end

    it "uses different root" do
      parent = AppView.root
      child  = AppViewRoot.root

      child.wont_equal(parent)
    end

    it 'a view must be included in the framework configuration registry' do
      Hanami::View.configuration.views.must_include(ConfigurationView)
      ConfigurationView.configuration.views.wont_include(ConfigurationView)
    end

    it 'a layout inheriths the configuration from the framework' do
      expected = Hanami::View.configuration
      actual   = ConfigurationLayout.configuration

      actual.must_equal(expected)
    end

    it 'a layout must be included in the framework configuration registry' do
      Hanami::View.configuration.layouts.must_include(ConfigurationLayout)
      ConfigurationLayout.configuration.layouts.wont_include(ConfigurationView)
    end
  end

  describe '.configure' do
    it 'allows to configure the framework' do
      path = Pathname.new('.').join('test/fixtures').realpath

      Hanami::View.class_eval do
        configure do
          root path
        end
      end

      Hanami::View.configuration.root.must_equal(path)
    end

    it 'allows to override one value' do
      Hanami::View.class_eval do
        configure do
          load_paths << 'test/fixtures'
        end

        configure do
          load_paths << 'test/fixtures/templates'
        end
      end

      configuration = Hanami::View.configuration
      configuration.load_paths.must_include('test/fixtures')
      configuration.load_paths.must_include('test/fixtures/templates')
    end
  end

  describe '.dupe' do
    before do
      Hanami::View.class_eval do
        configure do
          root '..'
        end
      end

      DuplicatedView = Hanami::View.dupe

      @framework_config  = Hanami::View.configuration
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

  describe '.duplicate' do
    before do
      Hanami::View.configure { layout :application }

      module Duplicated
        View = Hanami::View.duplicate(self)
      end

      module DuplicatedCustom
        View = Hanami::View.duplicate(self, 'Viewz')
      end

      module DuplicatedWithoutNamespace
        View = Hanami::View.duplicate(self, nil)
      end

      module DuplicatedConfigure
        View = Hanami::View.duplicate(self) do
          layout :app
        end

        module Views
          class AppLayout
            include DuplicatedConfigure::Layout
          end
        end
      end
    end

    after do
      Hanami::View.configuration.reset!

      Object.send(:remove_const, :Duplicated)
      Object.send(:remove_const, :DuplicatedCustom)
      Object.send(:remove_const, :DuplicatedWithoutNamespace)
      Object.send(:remove_const, :DuplicatedConfigure)
    end

    it 'duplicates the configuration of the framework' do
      actual   = Duplicated::View.configuration
      expected = Hanami::View.configuration

      actual.layout.must_equal(expected.layout)
    end

    it 'generates a namespace for views' do
      assert defined?(Duplicated::Views), 'Duplicated::Views expected'
    end

    it 'generates a custom namespace for views' do
      assert defined?(DuplicatedCustom::Viewz), 'DuplicatedCustom::Viewz expected'
    end

    it 'does not create a custom namespace for views' do
      assert !defined?(DuplicatedWithoutNamespace::Views), "DuplicatedWithoutNamespace::Views wasn't expected"
    end

    it 'assigns correct namespace to the configuration when the namespace argument is nil' do
      DuplicatedWithoutNamespace::View.configuration.namespace.must_equal 'DuplicatedWithoutNamespace'
    end

    it 'duplicates Layout' do
      assert defined?(Duplicated::Layout), 'Duplicated::Layout expected'
    end

    it 'duplicates Presenter' do
      assert defined?(Duplicated::Presenter), 'Duplicated::Presenter expected'
    end

    it 'optionally accepts a block to configure the generated module' do
      expected = DuplicatedConfigure::Views::AppLayout
      DuplicatedConfigure::View.configuration.layout.must_equal expected
    end
  end

  describe 'global layout' do
    before do
      Hanami::View.class_eval do
        configure do
          layout :application
        end
      end

      class ViewWithInheritedLayout
        include Hanami::View
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
