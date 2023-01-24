module Hanami
  class View
    module ContextHelpers
      module ContentHelpers
        def initialize(**)
          @content_for = {}
          super
        end

        def content_for(key, value = nil, &block)
          output = nil

          if block
            @content_for[key] = yield
          elsif value
            @content_for[key] = value
          else
            output = @content_for[key]
          end

          output
        end
      end
    end
  end
end
