module Dry
  module View
    class Exposure
      SUPPORTED_PARAMETER_TYPES = [:req, :opt].freeze

      attr_reader :name
      attr_reader :proc
      attr_reader :object
      attr_reader :to_view

      def initialize(name, proc = nil, object = nil, to_view: true)
        @name = name
        @proc = prepare_proc(proc, object)
        @object = object
        @to_view = to_view
      end

      def bind(obj)
        self.class.new(name, proc, obj, to_view: to_view)
      end

      def dependencies
        proc ? proc.parameters.map(&:last) : []
      end

      alias_method :to_view?, :to_view

      def call(input, locals = {})
        return input.fetch(name) unless proc

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
