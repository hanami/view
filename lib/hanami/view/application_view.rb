module Hanami
  class View
    class ApplicationView < Module
      InheritedHook = Class.new(Module)

      attr_reader :provider
      attr_reader :application
      attr_reader :inherited_hook

      def initialize(provider)
        @provider = provider
        @application = provider&.application || Hanami.application
        @inherited_hook = InheritedHook.new

        define_inherited_hook
      end

      def included(view_class)
        view_class.config.paths = [provider.root.join(application.config.views.templates_path).to_s]
        view_class.config.layouts_dir = application.config.views.layouts_dir
        view_class.config.layout = application.config.views.default_layout

        view_class.extend inherited_hook
      end

      private

      def define_inherited_hook
        template_name = method(:template_name)

        inherited_hook.define_method :inherited do |subclass|
          super(subclass)
          subclass.config.template = template_name.(subclass)
        end
      end

      def template_name(view_class)
        provider
          .inflector
          .underscore(view_class.name)
          .sub(/^#{provider.namespace_path}\//, "")
          .sub(/^#{application.config.views.base_path}\//, "")
      end
    end
  end
end
