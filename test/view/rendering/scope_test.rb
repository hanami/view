require 'test_helper'

describe Lotus::View::Rendering::Scope do
  describe '#respond_to?' do
    describe 'when the view implements the method' do
      it 'returns true' do
        scope = Lotus::View::Rendering::Scope.new(ViewForScopeTest.new)
        assert scope.respond_to?(:bar), "Expected scope to respond to `#bar'"
      end
    end

    describe 'when the scope implements the method' do
      it 'returns true' do
        scope = Lotus::View::Rendering::Scope.new(ViewForScopeTest.new, {x: 23})
        assert scope.respond_to?(:x), "Expected scope to respond to `#x'"
      end
    end

    describe "when both the view and the scope don't implement the method" do
      it 'returns false' do
        scope = Lotus::View::Rendering::Scope.new(ViewForScopeTest.new, {x: 23})
        assert !scope.respond_to?(:missing), "Expected scope to NOT respond to `#missing'"
      end
    end
  end
end
