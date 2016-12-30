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
        proc ? self : with_proc(obj.method(name))
      end

      def dependencies
        proc.parameters.map(&:last)
      end

      alias_method :to_view?, :to_view

      def call(input, locals = {})
        params = dependencies.map { |name|
          name == :input ? input : locals.fetch(name)
        }

        proc.(*params)
      end

      private

      def with_proc(proc)
        self.class.new(name, proc, to_view: to_view)
      end

      def ensure_proc_parameters(proc)
        if proc.parameters.any? { |type, _| !SUPPORTED_PARAMETER_TYPES.include?(type) }
          raise ArgumentError, "+proc+ must take positional arugments only"
        end
      end
    end
  end
end
