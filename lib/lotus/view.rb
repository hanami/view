require 'lotus/view/configuration'
require 'lotus/view/template'
require 'lotus/view/rendering'

module Lotus
  module View
    def self.included(base)
      base.class_eval do
        extend  Configuration
        extend  Template
        include Rendering
      end
    end

    def self.root=(root)
      @@root = Pathname.new(root)
    end

    def self.root
      @@root ||= Pathname.new(__dir__)
    end

    def self.engine=(engine)
      @@engine = engine
    end

    def self.engine
      @@engine ||= :erb
    end
  end
end
