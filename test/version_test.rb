require 'test_helper'

describe Lotus::View::VERSION do
  it 'returns current version' do
    Lotus::View::VERSION.must_equal '0.4.0'
  end
end
