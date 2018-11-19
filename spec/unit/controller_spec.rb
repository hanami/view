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
    double(:page, title: 'Test')
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
          config.renderer_options = {
            outvar: '@__buf__'
          }
        end
      end.new
    }

    subject(:context) {
      Class.new do
        def self.form(action:, &blk)
          new(action, &blk)
        end

        def initialize(action, &blk)
          @buf = eval('@__buf__', blk.binding)

          @buf << "<form action=\"#{action}\" method=\"post\">"
          blk.(self)
          @buf << '</form>'
        end

        def text(name)
          "<input type=\"text\" name=\"#{name}\" />"
        end
      end
    }

    it 'uses default encoding' do
      klass = Class.new(Dry::View::Controller)
      expect(klass.config.renderer_options).to be_a Hash
      expect(klass.config.renderer_options[:default_encoding]).to eql 'utf-8'
    end

    it 'are passed to renderer' do
      expect(controller.(context: context).to_s).to eq(
        '<form action="/people" method="post"><input type="text" name="name" /></form>'
      )
    end
  end
end
