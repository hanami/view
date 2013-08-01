require 'lotus/view/template'

module Lotus
  module View
    module Rendering
      class TemplateFinder
        def initialize(view)
          @view = view
        end

        def find
          Dir["#{ root }/#{ template_name }.*"].map do |template|
            Template.new template
          end
        end

        protected
        def template_name
          view.template
        end

        def root
          view.root
        end

        private
        attr_reader :view
      end
    end
  end
end
