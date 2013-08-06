require 'lotus/utils/string'
require 'lotus/view/rendering/layout_finder'

module Lotus
  module View
    module Dsl
      def root(value = nil)
        if value
          @@root = Pathname.new value
        else
          @@root ||= Lotus::View.root
        end
      end

      def format(value = nil)
        if value
          @format = value
        else
          @format
        end
      end

      def template(value = nil)
        if value
          @@template = value
        else
          @@template ||= Utils::String.new(name).underscore
        end
      end

      def layout(value = nil)
        if value
          @layout = value
        else
          @layout
        end
      end

      protected
      def load!
        super

        views.each do |v|
          v.root.freeze
          v.format.freeze
          v.template.freeze
          v.layout(Rendering::LayoutFinder.new(v).find)
          v.layout.freeze
        end
      end
    end
  end
end
