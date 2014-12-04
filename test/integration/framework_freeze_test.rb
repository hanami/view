require 'test_helper'

describe 'Framework freeze' do
  describe 'Lotus::View' do
    before do
      Lotus::View.unload!
      Lotus::View.load!
    end

    it 'freezes framework configuration' do
      Lotus::View.configuration.must_be :frozen?
    end

    it 'freezes view configuration' do
      AppView.configuration.must_be :frozen?
    end

    it 'freezes view subclass configuration' do
      AppViewLayout.configuration.must_be :frozen?
    end

    it 'freezes layout configuration' do
      ApplicationLayout.configuration.must_be :frozen?
    end
  end

  describe 'duplicated framework' do
    before do
      Store::View.unload!
      Store::View.load!
    end

    it 'freezes framework configuration' do
      Store::View.configuration.must_be :frozen?
    end

    it 'freezes view configuration' do
      Store::Views::Home::Index.configuration.must_be :frozen?
    end

    it 'freezes view subclass configuration' do
      Store::Views::Home::JsonIndex.configuration.must_be :frozen?
    end

    it 'freezes layout configuration' do
      Store::Views::StoreLayout.configuration.must_be :frozen?
    end
  end
end
