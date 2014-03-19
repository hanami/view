require 'test_helper'

describe Lotus::View do
  describe '.layout=' do
    before do
      Lotus::View.unload!

      class ViewWithInheritedLayout
        include Lotus::View
      end

      Lotus::View.layout = :application
      Lotus::View.load!
    end

    after do
      Lotus::View.unload!
      Object.send(:remove_const, :ViewWithInheritedLayout)
      Lotus::View.layout = nil
      Lotus::View.load!
    end

    it 'sets global layout' do
      ViewWithInheritedLayout.layout.must_equal ApplicationLayout
    end
  end
end
