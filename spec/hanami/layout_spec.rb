RSpec.describe Hanami::Layout do
  include_context 'reload configuration'

  describe 'rendering from layout' do
    it 'renders partial' do
      pending('something is wrong with the templates')

      rendered = IndexView.render(format: :html)
      expect(rendered).to match %(<div id="sidebar"></div>)
    end
  end

  it "raises subclassed error if template isn't found" do
    Hanami::View.unload!

    class MissingLayout
      include Hanami::Layout
    end

    expect do
      Hanami::View.load!
    end.to raise_error(Hanami::View::MissingTemplateLayoutError, "Can't find layout template 'MissingLayout'")

    # TODO: How do I do this in RSpec?
    # error.class.ancestors.must_include Hanami::View::Error
  end

  it 'concrete methods are available in layout template' do
    rendered = Store::Views::Home::Index.render(format: :html)
    expect(rendered).to match %(script)
    expect(rendered).to match %(yeah)
  end

  it 'methods defined in layout are available from the view' do
    rendered = Store::Views::Home::Index.render(format: :html)
    expect(rendered).to match %(Joe Blogs)
  end

  it 'renders content to return value from view' do
    rendered = Store::Views::Products::Show.render(format: :html)
    expect(rendered).to match %(Product)
    expect(rendered).to match %(<script src="/javascripts/product-tracking.js"></script>)
  end

  it 'renders content to return value from layout' do
    rendered = Store::Views::Products::Show.render(format: :html)
    expect(rendered).to match %(Product)
    expect(rendered).to match %(<meta name="hanamirb-version" content="0.3.1">)
  end

  describe 'disable layout in view' do
    it 'return NullLayout' do
      expect(DisabledLayoutView.layout).to eq Hanami::View::Rendering::NullLayout
    end
  end
end
