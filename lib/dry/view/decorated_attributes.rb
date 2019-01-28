require "set"

module Dry
  class View
    module DecoratedAttributes
      def self.included(klass)
        klass.extend ClassInterface
      end

      module ClassInterface
        MODULE_NAME = :DecoratedAttributes

        def decorate(*names, **options)
          decorated_attributes.decorate(*names, **options)
        end

        private

        def decorated_attributes
          if const_defined?(MODULE_NAME, false)
            const_get(MODULE_NAME)
          else
            const_set(MODULE_NAME, Attributes.new).tap do |mod|
              prepend mod
            end
          end
        end
      end

      class Attributes < Module
        def initialize(*)
          @names = Set.new
          super
        end

        def decorate(*names, **options)
          @names += names

          class_eval do
            names.each do |name|
              define_method name do
                attribute = super()

                if _render_env && attribute
                  _render_env.part(name, attribute, **options)
                else
                  attribute
                end
              end
            end
          end
        end

        def inspect
          %(#<#{self.class.name}#{@names.to_a.sort.inspect}>)
        end
      end
    end
  end
end
