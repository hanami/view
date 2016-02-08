require 'test_helper'

describe Hanami::View::VERSION do
  it 'returns current version' do
    Hanami::View::VERSION.must_equal '0.7.0'
  end
end
