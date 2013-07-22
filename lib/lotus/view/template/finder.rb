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
          underscore(view.template_name)
        end

        # TODO extract into Lotus::Utils::String#underscore
        def underscore(name)
          name.
            gsub('::', '/').
            gsub(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2').
            gsub(/([a-z\d])([A-Z])/,'\1_\2').
            downcase
        end
      end
    end
  end
end
