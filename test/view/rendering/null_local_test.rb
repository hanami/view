require 'test_helper'

describe Hanami::View::Rendering::NullLocal do
  before do
    @null = Hanami::View::Rendering::NullLocal.new(:result)
  end

  it 'does not complain for unknown sent messages' do
    actual = @null.foo

    actual.must_be_instance_of(Hanami::View::Rendering::NullLocal)
    actual.inspect.must_match ":result.foo"
  end

  it 'returns empty string for to_str' do
    @null.to_str.must_equal ''
  end

  it 'returns empty string for to_s' do
    @null.to_s.must_equal ''
  end

  it 'returns false to all?' do
    @null.all?.must_equal false
  end

  it 'returns false to any?' do
    @null.any?.must_equal false
  end

  it 'returns true to empty?' do
    @null.empty?.must_equal true
  end

  it 'returns true to nil?' do
    @null.nil?.must_equal true
  end

  it 'returns false to any method ending with question mark' do
    @null.downloadable?.must_equal false
  end

  it 'always returns true for respond_to? check' do
    @null.respond_to?(:bar).must_equal true
  end

  it 'contains the name of the local in #inspect' do
    @null.inspect.must_match ":result"
  end
end
