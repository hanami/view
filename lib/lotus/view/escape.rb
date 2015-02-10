require 'lotus/utils/escape'
require 'lotus/presenter'

module Lotus
  module View
    module Escape
      module InstanceMethods
        def _raw(input)
          ::Lotus::Utils::Escape::SafeString.new(input)
        end

        def _escape(object)
          ::Lotus::View::Escape::Presenter.new(object)
        end
      end

      class Presenter
        include ::Lotus::Presenter
      end

      def self.html(input)
        case input
        when String
          Utils::Escape.html(input)
        else
          input
        end
      end

      def self.extended(base)
        base.class_eval do
          include ::Lotus::Utils::ClassAttribute
          include ::Lotus::View::Escape::InstanceMethods

          class_attribute :autoescape_methods
          self.autoescape_methods = {}
        end
      end

      def method_added(method_name)
        unless autoescape_methods[method_name]
          prepend Module.new {
            module_eval %{
              def #{ method_name }(*args, &blk); ::Lotus::View::Escape.html super; end
            }
          }

          autoescape_methods[method_name] = true
        end
      end
    end
  end
end
