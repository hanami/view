# frozen_string_literal: true

require "set"

module Hanami
  class View
    # Decorates attributes in Parts.
    module DecoratedAttributes
      # @api private
      def self.included(klass)
        klass.extend ClassInterface
      end

      # Decorated attributes class-level interface.
      module ClassInterface
        # @api private
        MODULE_NAME = :DecoratedAttributes

        # Decorates the provided attributes, wrapping them in Parts using the
        # current render environment.
        #
        # @example
        #   class Article < Hanami::View::Part
        #     decorate :feature_image
        #     decorate :author as: :person
        #   end
        #
        # @param names [Array<Symbol>] the attribute names
        # @param options [Hash] the options to pass to the Part Builder
        # @option options [Symbol, Class] :as an alternative name or class to use when finding a
        #   matching Part
        #
        # @api public
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

      # @api private
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
