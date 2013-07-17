require 'pathname'
require 'tilt'
require 'lotus/view/template/finder'

module Lotus
  module View
    module Template
      def self.extended(base)
        base.class_eval do
          include InstanceMethods
        end
      end

      module InstanceMethods
        private
        def template
          self.class.template
        end
      end

      def path
        @path ||= Finder.new(self).find
      end

      def template
        @template ||= Tilt.new(path.to_s)
      end

      private
      def load!
        template
        nil
      end
    end
  end
end
