module Lotus
  module View
    class MissingTemplateError < ::Exception
      def initialize(view, path)
        super "Cannot find template for view: #{ view.name } (#{ path })."
      end
    end

    module Template
      class Finder
        def initialize(view)
          @view = view
        end

        def find
          begin
            Pathname.new(path).realpath
          rescue Errno::ENOENT
            raise MissingTemplateError.new(view, path)
          end
        end

        private
        attr_reader :view

        def path
          root.join relative_path + engine
        end

        def root
          view.root
        end

        def relative_path
          underscore(view.name)
        end

        def engine
          ".#{ view.engine }"
        end

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
