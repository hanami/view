require 'lotus/view/finder'
require 'lotus/view/template/finder'

module Lotus
  module View
    module Rendering
      class Registry
        class Registration < ::Hash
          def initialize(view, formats)
            super()
            _merge_entries!(view, formats)
          end

          private
          def _merge_entries!(view, formats)
            formats.each do |format|
              store format, _entry_for(view, format)
            end
          end

          # FIXME Code smell: `view` and `format` data clump
          def _entry_for(view, format)
            v = _view_for(view, format)
            [ v, _template_for(v, format) ]
          end

          def _view_for(view, format)
            Lotus::View::Finder.new(view, format).find
          end

          def _template_for(view, format)
            Lotus::View::Template::Finder.new(view, format).find
          end
        end
      end
    end
  end
end
