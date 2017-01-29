module Dry
  module View
    class Exposure
      SUPPORTED_PARAMETER_TYPES = [:req, :opt].freeze

      attr_reader :name
      attr_reader :proc
      attr_reader :to_view

      def initialize(name, proc = nil, to_view: true)
        ensure_proc_parameters(proc) if proc

        @name = name
        @proc = proc
        @to_view = to_view
      end

      def bind(obj)
        proc ? self : with_default_proc(obj)
      end

      def dependencies
        proc.parameters.map(&:last)
      end

      alias_method :to_view?, :to_view

      def call(input, locals = {})
        params = dependencies.map.with_index { |name, position|
          if position.zero?
            locals.fetch(name) { input }
          else
            locals.fetch(name)
          end
        }

        proc.(*params)
      end

      private

      def with_default_proc(obj)
        self.class.new(name, build_default_proc(obj), to_view: to_view)
      end

      def build_default_proc(obj)
        if obj.respond_to?(name, _include_private = true)
          obj.method(name)
        else
          -> input { input.fetch(name) }
        end
      end

      def ensure_proc_parameters(proc)
        if proc.parameters.any? { |type, _| !SUPPORTED_PARAMETER_TYPES.include?(type) }
          raise ArgumentError, "+proc+ must take positional arugments only"
        end
      end
    end
  end
end
