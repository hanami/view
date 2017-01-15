RSpec.describe Dry::View::Controller do
  subject(:layout) { layout_class.new }

  let(:layout_class) do
    klass = Class.new(Dry::View::Controller)

    klass.configure do |config|
      config.paths = SPEC_ROOT.join('fixtures/templates')
      config.layout = 'app'
      config.template = 'user'
      config.formats = {html: :slim}
    end

    klass
  end

  let(:page) do
    double(:page, title: 'Test')
  end

  let(:options) do
    { layout_scope: page, locals: { user: { name: 'Jane' }, header: { title: 'User' } } }
  end

  let(:renderer) do
    layout.class.renderers[:html]
  end

  describe '#call' do
    it 'renders template within the layout' do
      expect(layout.(options)).to eql(
        '<!DOCTYPE html><html><head><title>Test</title></head><body><h1>User</h1><p>Jane</p></body></html>'
      )
    end
  end
end
