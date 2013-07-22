require 'lotus/utils/string'
require 'lotus/view/template/null_template'

module Lotus
  module View
    class MissingTemplateError < ::Exception
      def initialize(view, path)
        super "Cannot find template for view: #{ view.name } (#{ path })."
      end
    end

    module Template
      class Finder
        def initialize(view, format)
          @view   = view
          @format = format
        end

        def find
          begin
            Tilt.new(absolute_path.to_s)
          rescue
            NullTemplate.new
          end
        end

        private
        attr_reader :view, :format

        def absolute_path
          Pathname.new(
            Dir[root.join "#{ relative_path }.{#{ format }}.*"].first
          ).realpath
        end

        def root
          view.root
        end

        def relative_path
          Utils::String.new(view.template_name).underscore
        end
      end
    end
  end
end
