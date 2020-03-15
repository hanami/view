# frozen_string_literal: true

require "tsort"
require "dry/equalizer"
require_relative "exposure"

module Hanami
  class View
    # @api private
    class Exposures
      include Dry::Equalizer(:exposures)
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

      def each(&block)
        exposures.each(&block)
      end

      def add(name, proc = nil, **options)
        exposures[name] = Exposure.new(name, proc, **options)
      end

      def import(name, exposure)
        exposures[name] = exposure.dup
      end

      def bind(obj)
        bound_exposures = exposures.each_with_object({}) { |(name, exposure), memo|
          memo[name] = exposure.bind(obj)
        }

        self.class.new(bound_exposures)
      end

      def call(input)
        # rubocop:disable Style/MultilineBlockChain
        tsort.each_with_object({}) { |name, memo|
          next unless (exposure = self[name])

          value = exposure.(input, memo)
          value = yield(value, exposure) if block_given?

          memo[name] = value
        }.each_with_object({}) { |(name, value), memo|
          memo[name] = value unless self[name].private?
        }
        # rubocop:enable Style/MultilineBlockChain
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
