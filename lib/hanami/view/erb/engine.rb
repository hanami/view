# frozen_string_literal: true

require "temple"

module Hanami
  class View
    module ERB
      # Hanami::View ERB engine.
      #
      # @api private
      # @since 2.0.0
      class Engine < Temple::Engine
        define_options capture_generator: Hanami::View::HTMLSafeStringBuffer

        use Parser
        use Filters::Block
        use Filters::Trimming
        filter :Escapable, use_html_safe: true
        filter :StringSplitter
        filter :StaticAnalyzer
        filter :MultiFlattener
        filter :StaticMerger
        generator :ArrayBuffer
      end
    end
  end
end
