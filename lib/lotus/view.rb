require 'lotus/view/template'
require 'lotus/view/rendering'

module Lotus
  module View
    def self.included(base)
      base.class_eval do
        extend  Template
        include Rendering
      end

      base.send(:load!)
    end

    def self.root=(root)
      @@root = Pathname.new(root)
    end

    def self.root
      @@root ||= Pathname.new(__dir__)
    end
  end
end
