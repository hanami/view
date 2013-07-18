require 'set'
require 'lotus/view/dsl'
require 'lotus/view/template'
require 'lotus/view/rendering'

module Lotus
  module View
    def self.included(base)
      base.class_eval do
        extend Dsl
        extend Template
        extend Rendering
      end
    end

    def self.root=(root)
      @@root = Pathname.new(root)
    end

    def self.root
      @@root ||= Pathname.new(__dir__)
    end

    def self.formats=(formats)
      @@formats = formats
    end

    def self.formats
      @@formats ||= Set.new [:html]
    end

    private
    def self.load!
    end
  end
end
