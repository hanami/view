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
        def templates
          self.class.templates
        end
      end

      def paths
        @paths ||= finder.find
      end

      def templates
        @templates ||= paths.map do |path|
          Tilt.new(path.to_s)
        end
      end

      def template_name
        ancestor.template_name
      end

      private
      def load!
        super
        finder
        templates
        nil
      end

      def finder
        @@finder ||= Finder.new(self)
      end
    end
  end
end
