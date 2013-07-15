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
        def body
          self.class.body
        end
      end

      def path
        @path ||= Finder.new(root, name).find
      end

      def body
        @body ||= Tilt.new(path.to_s)
      end

      private
      def load!
        body
        nil
      end

      def root
        Lotus::View.root
      end
    end
  end
end
