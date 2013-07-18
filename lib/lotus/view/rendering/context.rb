module Lotus
  module View
    module Rendering
      class Context
        attr_reader :format

        def initialize(format: format)
          @format = format
        end
      end
    end
  end
end
