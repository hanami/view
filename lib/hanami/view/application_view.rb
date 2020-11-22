module Hanami
  class View
    class ApplicationView < Module
      InheritedHook = Class.new(Module)

      attr_reader :provider
      attr_reader :application
      attr_reader :inherited_hook

      def initialize(provider)
        @provider = provider
        @application = provider.respond_to?(:application) ? provider.application : Hanami.application
        @inherited_hook = InheritedHook.new

        define_inherited_hook
      end

      def included(view_class)
        view_class.settings.each do |setting|
          if application.config.views.respond_to?(:"#{setting}")
            application_value = application.config.views.public_send(:"#{setting}")
            view_class.config.public_send :"#{setting}=", application_value
          end
        end

        view_class.config.inflector = provider.inflector
        view_class.config.paths = prepare_paths(provider, view_class.config.paths)

        view_class.extend inherited_hook
      end

      private

      def define_inherited_hook
        template_name = method(:template_name)

        inherited_hook.send :define_method, :inherited do |subclass|
          super(subclass)
          subclass.config.template = template_name.(subclass)
        end
      end

      def prepare_paths(provider, configured_paths)
        configured_paths.map { |path|
          if path.dir.relative?
            provider.root.join(path.dir)
          else
            path
          end
        }
      end

      def template_name(view_class)
        provider
          .inflector
          .underscore(view_class.name)
          .sub(/^#{provider.namespace_path}\//, "")
          .sub(/^#{view_class.config.template_inference_base}\//, "")
      end
    end
  end
end
