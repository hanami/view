module Lotus
  module View
    module Inheritable
      class NullAncestor
        def initialize(name)
          @name = name
        end

        def abstract?
          true
        end

        def remove_format(format)
        end

        def template_name
          @name
        end
      end
    end
  end
end
