module Dry
  module View
    module Tilt
      module Haml
        def self.requirements
          ["hamlit/block", <<~ERROR]
            dry-view requires hamlit-block for haml templates
          ERROR
        end

        def self.activate
          # requiring hamlit/block above registers the extension with Tilt
        end
      end

      register_adapter :haml, Haml
    end
  end
end
