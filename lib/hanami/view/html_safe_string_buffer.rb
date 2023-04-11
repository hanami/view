# frozen_string_literal: true

require "temple"

module Hanami
  class View
    # Speicalized Temple buffer class that marks block-captured strings as HTML safe.
    #
    # This is important for any scope or part methods that receive a string from a yielded block
    # and then determine whether to escape that string based on its `.html_safe?` value.
    #
    # In this case, since blocks captured templates _intentionally_ contain HTML (this is the
    # purpose of the template after all), it makes sense to mark the entire captured block string as
    # HTML safe.
    #
    # This is compatible with escaping of values interpolated into the template, since those will
    # have already been automatically escaped by the template engine when they are evaluated, before
    # the overall block is captured.
    #
    # This filter is included in all three of our supported HTML template engines (ERB, Haml and
    # Slim) to provide consistent behavior across all.
    #
    # @see Hanami::View::ERB::Engine
    # @see Hanami::View::HamlAdapter::Template
    # @see Hanami::View::SlimAdapter::Template
    #
    # @api private
    # @since 2.0.0
    class HTMLSafeStringBuffer < Temple::Generators::StringBuffer
      def return_buffer
        "#{buffer}.html_safe"
      end
    end
  end
end
