require 'test_helper'

describe Lotus::View::Rendering::LayoutScope do
  describe '#respond_to?' do
    before do
      layout     = LayoutForScopeTest.new
      view_scope = Lotus::View::Rendering::Scope.new(ViewForScopeTest.new)
      @scope     = Lotus::View::Rendering::LayoutScope.new(layout, view_scope)
    end

    describe 'when the layout implements the method' do
      it 'returns true' do
        assert @scope.respond_to?(:foo), "Expected @scope to respond to `#foo'"
      end
    end

    describe 'when the view scope implements the method' do
      it 'returns true' do
        assert @scope.respond_to?(:bar), "Expected @scope to respond to `#bar'"
      end
    end

    describe "when both the layout and the view scope don't implement the method" do
      it 'returns false' do
        assert !@scope.respond_to?(:missing), "Expected @scope to NOT respond to `#missing'"
      end
    end
  end
end
