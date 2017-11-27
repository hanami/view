RSpec.describe Hanami::View::Rendering::LayoutScope do
  before do
    layout = LayoutForScopeTest.new
    scope  = Hanami::View::Rendering::Scope.new(ViewForScopeTest.new)
    @scope = Hanami::View::Rendering::LayoutScope.new(layout, scope)
  end

  describe '#respond_to?' do
    describe 'when the layout implements the method' do
      it 'returns true' do
        expect(@scope).to respond_to(:foo), "Expected @scope to respond to `#foo'"
      end
    end

    describe 'when the view scope implements the method' do
      it 'returns true' do
        expect(@scope).to respond_to(:bar), "Expected @scope to respond to `#bar'"
      end
    end

    describe "when both the layout and the view scope don't implement the method" do
      it 'returns false' do
        expect(@scope).to_not respond_to(:missing), "Expected @scope to NOT respond to `#missing'"
      end
    end
  end

  describe '#class' do
    it 'returns proper class name' do
      expect(@scope.class).to eq Hanami::View::Rendering::LayoutScope
    end
  end

  describe '#inspect' do
    it 'returns proper inspect String' do
      expect(@scope.inspect).to include '@layout'
      expect(@scope.inspect).to include '@scope'
      expect(@scope.inspect).to include '%x' % (@scope.object_id << 1)
    end
  end

  describe '#method_missing' do
    describe 'method is defined on scope' do
      it 'returns result of foo method' do
        expect(@scope.foo).to eq 'x'
      end
    end

    describe 'undefined method on scope' do
      it 'raises NoMethodError' do
        expect do
          @scope.unknown
        end.to raise_error(NoMethodError, /undefined method `unknown'/)
      end
    end

    describe 'reference wrong method/variable' do
      it 'raises NameError' do
        expect do
          @scope.wrong_reference
        end.to raise_error(NameError, /undefined local variable or method `unknown_method'/)
      end
    end

    describe 'undefined method for local variable' do
      it 'raises NoMethodError' do
        expect do
          @scope.wrong_method
        end.to raise_error(NoMethodError, /undefined method `unknown'/)
      end
    end

    describe 'internal method invokation raises error' do
      it 'raises that error' do
        expect do
          @scope.raise_error
        end.to raise_error(ArgumentError, /nope/)
      end
    end
  end

  describe '#render' do
    describe 'render with no known render type' do
      it 'raises UnknownRenderTypeError' do
        expect do
          @scope.render(templte: "misspelled")
        end.to raise_error(Hanami::View::UnknownRenderTypeError, /Calls to `render` in a layout must include one of ':partial', ':template'. Found ':templte'./)
      end
    end
  end

end
