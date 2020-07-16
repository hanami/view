module Hanami
  module View
    module ContextHelpers
      module ContentFor
        def initialize(**options)
          super(**options.merge(content: {}))
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
