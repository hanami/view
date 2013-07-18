module Lotus
  module View
    module Rendering
      class Resolver
        def initialize(view)
          @view      = view
          @templates = _prepare_templates
        end

        def resolve(context)
          templates[context.format]
        end

        private
        attr_reader :templates

        def _prepare_templates
          {}.tap do |templates|
            @view.formats.each do |format|
              templates[format] = _template_for(format)
            end
          end
        end

        def _template_for(format)
          @view.templates.find {|template| File.fnmatch("*.#{ format }.*", template.basename) }
        end
      end
    end
  end
end
