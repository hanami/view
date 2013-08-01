require 'lotus/view/rendering/partial_finder'

module Lotus
  module View
    class Partial
      def initialize(view, options)
        @view, @options = view, options
      end

      def render
        template.render(view, locals)
      end

      protected
      def template
        Rendering::PartialFinder.new(view.class, options[:partial]).find
      end

      def locals
        options[:locals]
      end

      private
      attr_reader :view, :options
    end
  end
end
