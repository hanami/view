require 'test_helper'

describe Hanami::View::VERSION do
  it 'returns current version' do
    Hanami::View::VERSION.must_equal '1.0.0.rc1'
  end
end
