require 'set'
require 'pathname'
require 'lotus/view/version'
require 'lotus/view/inheritable'
require 'lotus/view/rendering'
require 'lotus/view/dsl'

module Lotus
  module View
    def self.included(base)
      base.class_eval do
        extend Inheritable.dup
        extend Dsl.dup
        extend Rendering.dup
      end

      views.add(base)
    end

    def self.root=(root)
      @@root = Pathname.new(root)
    end

    def self.root
      @@root ||= begin
        self.root = '.'
        @@root
      end
    end

    def self.views
      @@views ||= Set.new
    end

    def self.load!
      root.freeze
      views.freeze

      views.each do |view|
        view.send(:load!)
      end
    end
  end
end
