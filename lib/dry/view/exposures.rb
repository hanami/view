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

      def add(name, &block)
        @exposures[name] = Exposure.new(name, block)
      end

      def bind(obj)
        bound_exposures = exposures.map { |name, exposure|
          [name, exposure.bind(obj)]
        }.to_h

        self.class.new(bound_exposures)
      end

      def locals(input)
        tsort.each_with_object({}) { |name, memo|
          memo[name] = exposures[name].(input, memo) if exposures.key?(name)
        }
      end

      private

      def tsort_each_node(&block)
        exposures.each_key(&block)
      end

      def tsort_each_child(name, &block)
        exposures[name].dependencies.each(&block) if exposures.key?(name)
      end
    end
  end
end
