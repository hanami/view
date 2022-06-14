# frozen_string_literal: true

require "tilt/template"
require "erbse"
require "temple/html/safe"

module Hanami
  class View
    module Tilt
      class Reader
        def call(template)
          data = File.binread(template.file)

          if data.respond_to?(:force_encoding) && Encoding.default_external
            # Set it to the default external (without verifying)
            data.force_encoding(Encoding.default_external)
          end

          Temple::HTML::SafeString.new(data)
        end

        def to_proc
          method(:call).to_proc
        end
      end

      # Tilt template class copied from cells-erb gem
      class ErbseTemplate < ::Tilt::Template
        def initialize(*args)
          super(*args, &Reader.new)
        end

        def prepare
          @template = ::Erbse::Engine.new
        end

        def precompiled_template(_locals)
          @template.call(data)
        end
      end
    end
  end
end
