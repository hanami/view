RSpec.describe Hanami::View::Rendering::Scope do
  describe '#respond_to?' do
    describe 'when the view implements the method' do
      it 'returns true' do
        scope = Hanami::View::Rendering::Scope.new(ViewForScopeTest.new)
        expect(scope).to respond_to(:bar), "Expected scope to respond to `#bar'"
      end
    end

    describe 'when the scope implements the method' do
      it 'returns true' do
        scope = Hanami::View::Rendering::Scope.new(ViewForScopeTest.new, x: 23)
        expect(scope).to respond_to(:x), "Expected scope to respond to `#x'"
      end
    end

    describe "when both the view and the scope don't implement the method" do
      it 'returns false' do
        scope = Hanami::View::Rendering::Scope.new(ViewForScopeTest.new, x: 23)
        expect(scope).to_not respond_to(:missing), "Expected scope to NOT respond to `#missing'"
      end
    end
  end

  describe '#class' do
    it 'returns proper class name' do
      scope = Hanami::View::Rendering::Scope.new(ViewForScopeTest.new)
      expect(scope.class).to eq Hanami::View::Rendering::Scope
    end
  end

  describe '#inspect' do
    it 'returns proper inspect String' do
      scope = Hanami::View::Rendering::Scope.new(ViewForScopeTest.new, x: 23)
      expect(scope.inspect).to include '@view'
      expect(scope.inspect).to include '@locals'
      expect(scope.inspect).to include format('%<id>x', id: (scope.object_id << 1))
    end
  end
end
