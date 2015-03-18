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

  describe 'disable layout in view' do
    it 'return NullLayout' do
      DisabledLayoutView.layout.must_equal Lotus::View::Rendering::NullLayout
    end
  end
end
