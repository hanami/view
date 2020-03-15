# frozen_string_literal: true

require "dry-equalizer"

module Hanami
  class View
    # An exposure defined on a view
    #
    # @api private
    class Exposure
      include Dry::Equalizer(:name, :proc, :object, :options)

      EXPOSURE_DEPENDENCY_PARAMETER_TYPES = %i[req opt].freeze
      INPUT_PARAMETER_TYPES = %i[key keyreq keyrest].freeze

      attr_reader :name
      attr_reader :proc
      attr_reader :object
      attr_reader :options

      def initialize(name, proc = nil, object = nil, **options)
        @name = name
        @proc = prepare_proc(proc, object)
        @object = object
        @options = options
      end

      def bind(obj)
        self.class.new(name, proc, obj, **options)
      end

      def dependency_names
        if proc
          proc.parameters.each_with_object([]) { |(type, name), names|
            names << name if EXPOSURE_DEPENDENCY_PARAMETER_TYPES.include?(type)
          }
        else
          []
        end
      end

      def input_keys
        if proc
          proc.parameters.each_with_object([]) { |(type, name), keys|
            keys << name if INPUT_PARAMETER_TYPES.include?(type)
          }
        else
          []
        end
      end

      def for_layout?
        options.fetch(:layout) { false }
      end

      def decorate?
        options.fetch(:decorate) { true }
      end

      def private?
        options.fetch(:private) { false }
      end

      def default_value
        options[:default]
      end

      def call(input, locals = {})
        if proc
          call_proc(input, locals)
        else
          input.fetch(name) { default_value }
        end
      end

      private

      def call_proc(input, locals)
        args, keywords = proc_args(input, locals)

        if keywords.empty?
          if proc.is_a?(Method)
            proc.(*args)
          else
            object.instance_exec(*args, &proc)
          end
        else
          if proc.is_a?(Method)
            proc.(*args, **keywords)
          else
            object.instance_exec(*args, **keywords, &proc)
          end
        end
      end

      def proc_args(input, locals)
        dependency_args = proc_dependency_args(locals)
        keywords = proc_input_args(input)

        if keywords.empty?
          [dependency_args, {}]
        else
          [dependency_args, keywords]
        end
      end

      def proc_dependency_args(locals)
        dependency_names.map { |name| locals.fetch(name) }
      end

      def proc_input_args(input)
        input_keys.each_with_object({}) { |key, args|
          args[key] = input[key] if input.key?(key)
        }
      end

      def prepare_proc(proc, object)
        if proc
          proc
        elsif object.respond_to?(name, _include_private = true)
          object.method(name)
        end
      end
    end
  end
end
