require 'test_helper'

describe Lotus::View do
  describe 'version' do
    it 'declares framework version' do
      Lotus::View::VERSION.must_equal '0.0.1'
    end
  end
end
