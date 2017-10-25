RSpec.describe Hanami::Layout do
  include_context 'reload configuration'

  describe 'rendering from layout' do
    it 'renders partial' do
      rendered = IndexView.render(format: :html)
      expect(rendered).to match %(<div id="sidebar"></div>)
    end
  end

  it "raises subclassed error if template isn't found" do
    Hanami::View.unload!

    class MissingLayout
      include Hanami::Layout
    end

    begin
      Hanami::View.load!
    rescue => error
      expect(error).to be_a(Hanami::View::MissingTemplateLayoutError)
      expect(error.message).to eq("Can't find layout template 'MissingLayout'")
      expect(error.class).to be < Hanami::View::Error
    end
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

  it 'renders optional content from layout' do
    rendered = Store::Views::Products::Show.render(format: :html, flash: { notice: "Product successfully updated" })
    expect(rendered).to match %(<div class="flash-notice">Product successfully updated</div>)
  end

  describe 'disable layout in view' do
    it 'return NullLayout' do
      expect(DisabledLayoutView.layout).to eq Hanami::View::Rendering::NullLayout
    end
  end
end
