require 'lotus/utils/escape'

module Lotus
  module View
    module Escape
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
          include Lotus::Utils::ClassAttribute
          include InstanceMethods

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

      module InstanceMethods
        def raw(input)
          Lotus::Utils::Escape::SafeString.new(input)
        end
      end
    end
  end
end
