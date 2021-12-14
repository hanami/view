require_relative "../view"
require "hanami/component"

module Hanami
  class View
    class ApplicationView < View
      extend Hanami::Component

      def self.inherited(view_class)
        super(view_class)
        if view_class.superclass == ApplicationView
          configure_view view_class
          inherited_hook = define_inherited_hook
          view_class.extend inherited_hook
        end
      end

      private

      def self.configure_view(view_class)
        view_class.settings.each do |setting|
          if application.config.views.respond_to?(:"#{setting}")
            application_value = application.config.views.public_send(:"#{setting}")
            view_class.config.public_send :"#{setting}=", application_value
          end
        end

        view_class.config.inflector = view_class.provider.inflector
        view_class.config.paths = prepare_paths(view_class.provider, view_class.config.paths)
        view_class.config.template = template_name(view_class)

        if (part_namespace = namespace_from_path(view_class, application.config.views.parts_path))
          view_class.config.part_namespace = part_namespace
        end
      end

      def self.define_inherited_hook
        inherited_hook = Class.new(Module).new
        template_name = method(:template_name)

        inherited_hook.send :define_method, :inherited do |subclass|
          super(subclass)
          subclass.config.template = template_name.(subclass)
        end
        inherited_hook
      end

      def self.prepare_paths(provider, configured_paths)
        configured_paths.map { |path|
          if path.dir.relative?
            provider.root.join(path.dir)
          else
            path
          end
        }
      end

      def self.template_name(view_class)
        view_class
          .provider
          .inflector
          .underscore(view_class.name)
          .sub(/^#{view_class.provider.namespace_path}\//, "")
          .sub(/^#{view_class.config.template_inference_base}\//, "")
      end

      def self.namespace_from_path(view_class, path)
        path = "#{view_class.provider.namespace_path}/#{path}"

        begin
          require path
        rescue LoadError => exception
          raise exception unless exception.path == path
        end

        begin
          inflector(view_class).constantize(inflector(view_class).camelize(path))
        rescue NameError => exception
        end
      end

      def self.inflector(view_class)
        view_class.provider.inflector
      end
    end
  end
end
