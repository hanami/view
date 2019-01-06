require "tilt/erubi"

RSpec.describe Dry::View::Controller do
  subject(:controller) {
    Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'user'
      end

      expose :user do
        {name: 'Jane'}
      end

      expose :header do
        {title: 'User'}
      end
    end.new
  }

  let(:context) do
    Class.new(Dry::View::Context) do
      def title
        'Test'
      end
    end.new
  end

  describe '#call' do
    it 'renders template within the layout' do
      expect(controller.(context: context).to_s).to eql(
        '<!DOCTYPE html><html><head><title>Test</title></head><body><h1>User</h1><p>Jane</p></body></html>'
      )
    end

    it 'provides a meaningful error if the template name is missing' do
      controller = Class.new(Dry::View::Controller) do
        configure do |config|
          config.paths = SPEC_ROOT.join('fixtures/templates')
        end
      end.new

      expect { controller.(context: context) }.to raise_error Dry::View::Controller::UndefinedTemplateError
    end
  end

  describe 'renderer options' do
    subject(:controller) {
      Class.new(Dry::View::Controller) do
        configure do |config|
          config.paths = SPEC_ROOT.join('fixtures/templates')
          config.template = 'controller_renderer_options'
          config.renderer_engine_mapping = {erb: Tilt::ErubiTemplate}
          config.renderer_options = {outvar: '@__buf__'}
        end
      end.new
    }

    before do
      module Test
        class Form
          def initialize(action, &block)
            @buf = eval('@__buf__', block.binding)

            @buf << "<form action=\"#{action}\" method=\"post\">"
            block.(self)
            @buf << '</form>'
          end

          def text(name)
            "<input type=\"text\" name=\"#{name}\" />"
          end
        end
      end
    end

    subject(:context) {
      Class.new(Dry::View::Context) do
        def form(action:, &blk)
          Test::Form.new(action, &blk)
        end
      end.new
    }

    it 'merges configured options with default encoding' do
      expect(controller.class.config.renderer_options[:outvar]).to eq '@__buf__'
      expect(controller.class.config.renderer_options[:default_encoding]).to eq 'utf-8'
    end

    it 'are passed to renderer' do
      expect(controller.(context: context).to_s.gsub(/\n\s*/m, "")).to eq(
        '<form action="/people" method="post"><input type="text" name="name" /></form>'
      )
    end
  end
end
