require 'dry-equalizer'

module Dry
  module View
    class Exposure
      include Dry::Equalizer(:name, :proc, :object, :options)

      SUPPORTED_PARAMETER_TYPES = [:req, :opt].freeze

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

      def dependencies
        proc ? proc.parameters.map(&:last) : []
      end

      def private?
        options.fetch(:private) { false }
      end

      def call(input, locals = {})
        return input[name] unless proc

        args = dependencies.map.with_index { |name, position|
          if position.zero?
            locals.fetch(name) { input }
          else
            locals.fetch(name)
          end
        }

        call_proc(*args)
      end

      private

      def call_proc(*args)
        if proc.is_a?(Method)
          proc.(*args)
        else
          object.instance_exec(*args, &proc)
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
