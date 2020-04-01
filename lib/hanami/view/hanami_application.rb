# frozen_string_literal: true

module Hanami
  class View
    class << self
      def [](slice_name)
        application = Hanami.application
        slice = slice_name.is_a?(Symbol) ? application.slices[slice_name] : slice_name

        templates_path = slice.root.join(application.config.views.templates_path).to_s

        klass = Class.new(self) do
          config.paths = [templates_path]
          config.layouts_dir = application.config.views.layouts_dir
          config.layout = application.config.views.default_layout
        end

        klass.define_singleton_method :inherited do |subclass|
          super(subclass)

          unless subclass.superclass == klass
            subclass.config.template = template_name(subclass, slice)
          end
        end

        klass
      end

      private

      def template_name(view_class, slice)
        slice.inflector.underscore(view_class.name)
          .sub(/^#{slice.namespace_path}\//, "")
          .sub(/^#{slice.application.config.views.base_path}\//, "")
      end
    end
  end
end
