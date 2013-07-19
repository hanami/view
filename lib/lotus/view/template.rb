module Lotus
  module View
    module Template
      def template_name
        ancestor.template_name
      end
    end
  end
end
