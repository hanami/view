require 'test_helper'
require 'support/reload_configuration_helper'

describe Hanami::Layout do
  reload_configuration!

  describe 'rendering from layout' do
    it 'renders partial'
    # it 'renders partial' do
    #   rendered = Test::IndexView.render(format: :html)
    #   rendered.must_match %(<div id="sidebar"></div>)
    # end
  end

  it "raise subclassed error if template isn't found" do
    Hanami::View.unload!

    class MissingLayout
      include Hanami::Layout
    end

    error = -> {
      Hanami::View.load!
    }.must_raise(Hanami::View::MissingTemplateLayoutError)
    error.message.must_include "Can't find layout template 'MissingLayout'"
    error.class.ancestors.must_include Hanami::View::Error
  end

  it 'concrete methods are available in layout template' do
    with_silenced_deprecation do
      rendered = Store::Views::Home::Index.render(format: :html)
      rendered.must_match %(script)
      rendered.must_match %(yeah)
    end
  end

  it 'methods defined in layout are available from the view' do
    with_silenced_deprecation do
      rendered = Store::Views::Home::Index.render(format: :html)
      rendered.must_match %(Joe Blogs)
    end
  end

  it 'renders content to return value from view' do
    with_silenced_deprecation do
      rendered = Store::Views::Products::Show.render(format: :html)
      rendered.must_match %(Product)
      rendered.must_match %(<script src="/javascripts/product-tracking.js"></script>)
    end
  end

  it 'renders content to return value from layout' do
    with_silenced_deprecation do
      rendered = Store::Views::Products::Show.render(format: :html)
      rendered.must_match %(Product)
      rendered.must_match %(<meta name="hanamirb-version" content="0.3.1">)
    end
  end

  it 'deprecates #content' do
    _, err = capture_io do
      Store::Views::Products::Show.render(format: :html)
    end

    err.must_match "#content is deprecated, please use #local"
  end

  describe 'disable layout in view' do
    it 'return NullLayout' do
      Test::DisabledLayoutView.layout.must_equal Hanami::View::Rendering::NullLayout
    end
  end

  private

  require 'hanami/utils/io'
  def with_silenced_deprecation(&blk)
    Hanami::Utils::IO.silence_warnings(&blk)
  end
end
