require 'test_helper'

describe Lotus::View do
  describe 'root' do
    it 'exposes the path where to lookup for templates' do
      expected = Pathname.new __dir__ + '/fixtures/templates'
      Lotus::View.root.must_equal expected
    end

    it 'is inherited' do
      HelloWorldView.root.must_equal Lotus::View.root
    end

    it 'can be customized for each view' do
      expected = Pathname.new __dir__ + '/fixtures/templates/app'
      AppView.root.must_equal expected
    end

    describe 'when not set' do
      before do
        @root = Lotus::View.root
        Lotus::View.class_variable_set(:@@root, nil)
      end

      after do
        Lotus::View.root = @root
      end

      it 'sets the current directory as root' do
        Lotus::View.root.must_equal Pathname.new('.')
      end
    end
  end
end
