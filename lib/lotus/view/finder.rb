require 'lotus/view/null_view'

module Lotus
  module View
    class Finder
      def initialize(view, format)
        @view, @format = view, format
      end

      def find
        views.find {|view| view.formats.include?(@format) } || NullView
      end

      private
      def views
        @view.subclasses + [ @view ]
      end
    end
  end
end
