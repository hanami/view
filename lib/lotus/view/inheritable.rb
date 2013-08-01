module Lotus
  module View
    module Inheritable
      def inherited(base)
        subclasses.add base
      end

      def subclasses
        @@subclasses ||= Set.new
      end

      protected
      def load!
        subclasses.freeze
        views.freeze
      end

      def views
        @@views ||= [ self ] + subclasses.to_a
      end
    end
  end
end
