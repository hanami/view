# frozen_string_literal: true

module Hanami
  class View
    module Tilt
      module ERB
        def self.requirements
          ["hanami/view/tilt/erbse", <<~ERROR]
            hanami-view requires erbse for full compatibility when rendering .erb templates (e.g. implicitly capturing block content when yielding)

            To ignore this and use another engine for .erb templates, deregister this adapter before calling your views:

            Hanami::View::Tilt.deregister_adapter(:erb)
          ERROR
        end

        def self.activate
          Tilt.default_mapping.register ErbseTemplate, "erb"
          self
        end
      end

      register_adapter :erb, ERB
    end
  end
end
