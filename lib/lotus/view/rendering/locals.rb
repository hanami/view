module Lotus
  module View
    module Rendering
      class Locals < ::Hash
        def initialize(values)
          super()
          merge!(values)
        end

        def modulize
          Module.new.tap do |mod|
            each do |m,v|
              mod.send :define_method, m, -> { v }
            end
          end
        end
      end
    end
  end
end
