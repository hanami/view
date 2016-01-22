require 'test_helper'

describe Hanami::View::Rendering::LayoutScope do
  before do
    layout     = LayoutForScopeTest.new
    view_scope = Hanami::View::Rendering::Scope.new(ViewForScopeTest.new)
    @scope     = Hanami::View::Rendering::LayoutScope.new(layout, view_scope)
  end

  describe '#respond_to?' do
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

  describe '#class' do
    it 'returns proper class name' do
      @scope.class.must_equal Hanami::View::Rendering::LayoutScope
    end
  end

  describe '#inspect' do
    it 'returns proper inspect String' do
      @scope.inspect.must_include '@layout'
      @scope.inspect.must_include '@scope'
      @scope.inspect.must_include '%x' % (@scope.object_id << 1)
    end
  end

  describe '#method_missing' do
    describe 'method is defined on scope' do
      it 'returns result of foo method' do
        @scope.foo.must_equal 'x'
      end
    end

    describe 'undefined method on scope' do
      it 'raises NoMethodError' do
        exception = -> { @scope.unknown }.must_raise NoMethodError
        exception.message.must_include 'undefined method `unknown'
      end
    end

    describe 'reference wrong method/variable' do
      it 'raises NameError' do
        exception = -> { @scope.wrong_reference }.must_raise NameError
        exception.message.must_include "undefined local variable or method `unknown_method'"
      end
    end

    describe 'undefined method for local variable' do
      it 'raises NoMethodError' do
        exception = -> { @scope.wrong_method }.must_raise NoMethodError
        exception.message.must_include 'undefined method `unknown'
      end
    end

    describe 'internal method invokation raises error' do
      it 'raises that error' do
        exception = -> { @scope.raise_error }.must_raise ArgumentError
        exception.message.must_include 'nope'
      end
    end
  end
end
