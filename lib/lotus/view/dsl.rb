require 'lotus/utils/string'
require 'lotus/view/rendering/layout_finder'

module Lotus
  module View
    module Dsl
      # TODO extract an elegant solution in Utils
      def root(value = nil)
        if value
          @@root = Pathname.new value
        else
          @@root ||= Lotus::View.root
        end
      end

      # TODO extract an elegant solution in Utils
      def format(value = nil)
        if value
          @format = value
        else
          @format
        end
      end

      # TODO extract an elegant solution in Utils
      def template(value = nil)
        if value
          @@template = value
        else
          @@template ||= Utils::String.new(name).underscore
        end
      end

      # TODO extract an elegant solution in Utils
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

        #FIXME this code has an intimate knowledge of a view
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
