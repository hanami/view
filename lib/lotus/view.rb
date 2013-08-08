require 'set'
require 'pathname'
require 'lotus/view/version'
require 'lotus/view/inheritable'
require 'lotus/view/rendering'
require 'lotus/view/dsl'
require 'lotus/view/layout'

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
      @root = Pathname.new(root) rescue nil
    end

    def self.root
      @root ||= begin
        self.root = '.'
        @root
      end
    end

    def self.layout=(layout)
      @layout = Rendering::LayoutFinder.find(layout)
    end

    def self.layout
      @layout ||= Rendering::NullLayout
    end

    def self.views
      @views ||= Set.new
    end

    def self.layouts
      @layouts ||= Set.new
    end

    def self.load!
      root.freeze
      layout.freeze
      views.freeze

      views.each do |view|
        view.send(:load!)
      end

      layouts.each do |layout|
        layout.send(:load!)
      end
    end
  end
end
