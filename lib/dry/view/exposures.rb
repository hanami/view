require "tsort"
require "dry/view/exposure"

module Dry
  module View
    class Exposures
      include TSort

      attr_reader :exposures

      def initialize(exposures = {})
        @exposures = exposures
      end

      def key?(name)
        exposures.key?(name)
      end

      def [](name)
        exposures[name]
      end

      def add(name, proc = nil, **options)
        exposures[name] = Exposure.new(name, proc, options)
      end

      def bind(obj)
        bound_exposures = exposures.each_with_object({}) { |(name, exposure), memo|
          memo[name] = exposure.bind(obj)
        }

        self.class.new(bound_exposures)
      end

      def locals(input)
        tsort.each_with_object({}) { |name, memo|
          memo[name] = self[name].(input, memo) if exposures.key?(name)
        }.each_with_object({}) { |(name, val), memo|
          memo[name] = val unless self[name].private?
        }
      end

      private

      def tsort_each_node(&block)
        exposures.each_key(&block)
      end

      def tsort_each_child(name, &block)
        self[name].dependency_names.each(&block) if exposures.key?(name)
      end
    end
  end
end
