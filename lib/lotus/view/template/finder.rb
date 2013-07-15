module Lotus
  module View
    class MissingTemplateError < ::Exception
    end

    module Template
      class Finder
        def initialize(root, name)
          @root, @name = root, name
        end

        def find
          begin
            Pathname.new(Dir["#{ @root.join(underscore(@name)) }.*"].first).realpath
          rescue TypeError
            raise MissingTemplateError
          end
        end

        def underscore(name)
          name.
            gsub(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2').
            gsub(/([a-z\d])([A-Z])/,'\1_\2').
            downcase
        end
      end
    end
  end
end
