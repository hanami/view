require 'test_helper'

describe Hanami::View::Rendering::NullLocal do
  before do
    @null = Hanami::View::Rendering::NullLocal.new(:result)
  end

  it 'does not complain for uknown sent messages' do
    @null.foo.must_be_nil
  end

  it 'returns true to nil?' do
    assert @null.nil?, "Expect #{ @null } to be #nil?"
  end

  it 'always returns true for respond_to? check' do
    @null.respond_to?(:bar).must_equal true
  end

  it 'contains the name of the local in #inspect' do
    @null.inspect.must_match ":result"
  end
end
