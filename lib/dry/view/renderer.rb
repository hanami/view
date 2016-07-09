require 'tilt'
require 'dry-equalizer'

module Dry
  module View
    class Renderer
      include Dry::Equalizer(:paths, :format, :engine)

      TemplateNotFoundError = Class.new(StandardError)

      attr_reader :paths, :format, :engine, :tilts

      def self.tilts
        @__engines__ ||= {}
      end

      def initialize(paths, options = {})
        @paths = paths
        @format = options.fetch(:format)
        @engine = options.fetch(:engine)
        @tilts = self.class.tilts
      end

      def call(template, scope, &block)
        path = lookup(template)

        if path
          render(path, scope, &block)
        else
          msg = "Template #{template} could not be found in paths:\n#{paths.map { |pa| "- #{pa.to_s}" }.join("\n")}"
          raise TemplateNotFoundError, msg
        end
      end

      def render(path, scope, &block)
        tilt(path).render(scope, &block)
      end

      def chdir(dirname)
        new_paths = paths.map { |path| path.chdir(dirname) }

        self.class.new(new_paths, engine: engine, format: format)
      end

      def lookup(name)
        template_name = "#{name}.#{format}.#{engine}"

        paths.inject(false) { |result, path|
          result || path.lookup(template_name)
        }
      end

      private

      def tilt(path)
        tilts.fetch(path) { tilts[path] = Tilt[engine].new(path, nil, default_encoding: "utf-8") }
      end
    end
  end
end
