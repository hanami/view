module Dry
  module View
    module Tilt
      module ERB
        def self.requirements
          ["dry/view/tilt/erbse", <<~ERROR]
            dry-view requires erbse for erb templates
          ERROR
        end

        def self.activate
          Tilt.default_mapping.register ErbseTemplate, 'erb'
          self
        end
      end

      register_adapter :erb, ERB
    end
  end
end
