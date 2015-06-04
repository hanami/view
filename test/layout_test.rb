require 'test_helper'

describe Lotus::Layout do
  describe 'rendering from layout' do
    it 'renders partial' do
      rendered = IndexView.render(format: :html)
      rendered.must_match %(<div id="sidebar"></div>)
    end
  end

  it "raise error if template isn't found" do
    Lotus::View.unload!

    class MissingLayout
      include Lotus::Layout
    end

    error = -> {
      Lotus::View.load!
    }.must_raise(Lotus::View::Rendering::MissingTemplateLayoutError)
    error.message.must_include "Can't find layout template 'MissingLayout'"
  end

  it 'concrete methods are available in layout template' do
    rendered = Store::Views::Home::Index.render(format: :html)
    rendered.must_match %(script)
    rendered.must_match %(yeah)
  end

  it 'methods defined in layout are available from the view' do
    rendered = Store::Views::Home::Index.render(format: :html)
    rendered.must_match %(Joe Blogs)
  end

  it 'renders content to return value from view' do
    rendered = Store::Views::Products::Show.render(format: :html)
    rendered.must_match %(Product)
    rendered.must_match %(<script src="/javascripts/product-tracking.js"></script>)
  end

  it 'renders content to return value from layout' do
    rendered = Store::Views::Products::Show.render(format: :html)
    rendered.must_match %(Product)
    rendered.must_match %(<meta name="lotusrb-version" content="0.3.1">)
  end

  describe 'disable layout in view' do
    it 'return NullLayout' do
      DisabledLayoutView.layout.must_equal Lotus::View::Rendering::NullLayout
    end
  end
end
