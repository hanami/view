require 'lotus/view/rendering/null_template'
require 'lotus/view/rendering/templates_finder'

module Lotus
  module View
    module Rendering
      class LayoutRegistry < ::Hash
        def initialize(view)
          super()

          @view = view
          prepare!
        end

        def resolve(context)
          fetch(context[:format], NullTemplate.new)
        end

        protected
        def prepare!
          templates.each do |template|
            merge! template.format => template
          end
        end

        def templates
          TemplatesFinder.new(@view).find
        end
      end
    end
  end
end
