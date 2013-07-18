require 'lotus/view/inheritable/null_ancestor'

module Lotus
  module View
    module Inheritable
      protected
      def set_ancestor(ancestor, klass)
        @ancestor = ancestor.abstract? ? klass : ancestor
      end

      def ancestor
        @ancestor ||= NullAncestor.new(name)
      end

      def abstract?
        !!@abstract
      end

      private
      def abstract!
        @abstract = true
      end

      def inherited(subclass)
        unless abstract?
          @@subclasses ||= Set.new
          @@subclasses.add(subclass)

          subclass.set_ancestor(ancestor, self)
        end
      end

      def subclasses
        @@subclasses
      end
    end
  end
end
