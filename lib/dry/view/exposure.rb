require 'dry-equalizer'

module Dry
  module View
    class Exposure
      include Dry::Equalizer(:name, :proc, :object, :options)

      EXPOSURE_DEPENDENCY_PARAMETER_TYPES = [:req, :opt].freeze
      INPUT_PARAMETER_TYPES = [:key, :keyreq, :keyrest].freeze

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
        self.class.new(name, proc, obj, options)
      end

      def dependency_names
        if proc
          proc.parameters.select { |param_info|
            EXPOSURE_DEPENDENCY_PARAMETER_TYPES.include?(param_info.first)
          }.map(&:last)
        else
          []
        end
      end

      def private?
        options.fetch(:private) { false }
      end

      def call(input, locals = {})
        return input[name] unless proc

        dependency_args = dependency_names.map { |name|
          locals.fetch(name)
        }

        call_proc(input, *dependency_args)
      end

      private

      def call_proc(input, *dependency_args)
        args = proc_args(input, *dependency_args)

        if proc.is_a?(Method)
          proc.(*args)
        else
          object.instance_exec(*args, &proc)
        end
      end

      def proc_args(input, *dependency_args)
        input_args = keyword_args(input)

        if input_args.any?
          dependency_args << input_args
        else
          dependency_args
        end
      end

      def keyword_args(input)
        proc.parameters.each_with_object({}) do |(type, name), args|
          if INPUT_PARAMETER_TYPES.include?(type) && input.key?(name)
            args[name] = input[name]
          end
        end
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
