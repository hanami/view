module Hanami
  class View
    module ContextHelpers
      module ContentHelpers
        def initialize(content: {}, **options)
          super
        end

        def content_for(key, value = nil, &block)
          content = _options[:content]
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
