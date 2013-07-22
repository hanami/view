require 'test_helper'

describe Lotus::Utils::String do
  describe '#underscore' do
    it 'keep self untouched' do
      string = Lotus::Utils::String.new('Lotus')
      string.underscore
      string.must_equal 'Lotus'
    end

    it 'removes all the upcase characters' do
      string = Lotus::Utils::String.new('Lotus')
      string.underscore.must_equal 'lotus'
    end

    it 'transforms camel case class names' do
      string = Lotus::Utils::String.new('LotusView')
      string.underscore.must_equal 'lotus_view'
    end

    it 'substitutes double colons with path separators' do
      string = Lotus::Utils::String.new('Lotus::View')
      string.underscore.must_equal 'lotus/view'
    end
  end
end
