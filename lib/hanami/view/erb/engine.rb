# frozen_string_literal: true

require "temple"
require_relative "parser"
require_relative "filters/block"
require_relative "filters/trimming"

module Hanami
  class View
    module ERB
      # Hanami::View ERB engine.
      #
      # @api private
      # @since 2.0.0
      class Engine < Temple::Engine
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
