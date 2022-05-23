module Hanami
  class View
    module ContextHelpers
      module ContentHelpers
        attr_reader :content
        private :content

        def initialize(*)
          super
          @content = {}
        end

        def content_for(key, value = nil, &block)
          output = nil

          if block
            content[key] = yield
          elsif value
            content[key] = value
          else
            output = content[key]
          end

          output
        end
      end
    end
  end
end
