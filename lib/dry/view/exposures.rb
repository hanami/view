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

      def [](name)
        exposures[name]
      end

      def add(name, proc = nil, **options)
        exposures[name] = Exposure.new(name, proc, **options)
      end

      def bind(obj)
        bound_exposures = Hash[exposures.map { |name, exposure|
          [name, exposure.bind(obj)]
        }]

        self.class.new(bound_exposures)
      end

      def locals(input)
        tsort.each_with_object({}) { |name, memo|
          memo[name] = self[name].(input, memo) if exposures.key?(name)
        }.each_with_object({}) { |(name, val), memo|
          memo[name] = val if self[name].to_view?
        }
      end

      private

      def tsort_each_node(&block)
        exposures.each_key(&block)
      end

      def tsort_each_child(name, &block)
        self[name].dependencies.each(&block) if exposures.key?(name)
      end
    end
  end
end
