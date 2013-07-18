module Lotus
  module View
    class MissingTemplateError < ::Exception
      def initialize(view, path = nil)
        super "Cannot find template for view: #{ view.name } (#{ path })."
      end
    end

    module Template
      class Finder
        def initialize(view)
          @view = view
        end

        def find
          _map_paths do |path|
            Pathname.new(path).realpath
          end
        end

        private
        attr_reader :view

        def paths
          @paths ||= Dir[root.join "#{ relative_path }.{#{ formats }}.*"]
        end

        def root
          view.root
        end

        def relative_path
          underscore(view.template_name)
        end

        def formats
          view.formats.to_a.join(',')
        end

        def underscore(name)
          name.
            gsub('::', '/').
            gsub(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2').
            gsub(/([a-z\d])([A-Z])/,'\1_\2').
            downcase
        end

        def _map_paths
          raise MissingTemplateError.new(view) if paths.empty?

          begin
            paths.map do |path|
              yield path
            end
          rescue Errno::ENOENT
            raise MissingTemplateError.new(view, path)
          end
        end
      end
    end
  end
end
