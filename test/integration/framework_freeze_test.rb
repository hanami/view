require 'test_helper'

describe 'Framework freeze' do
  describe 'Hanami::View' do
    before do
      Hanami::View.unload!
      Hanami::View.load!
    end

    it 'freezes framework configuration' do
      Hanami::View.configuration.must_be :frozen?
    end

    it 'freezes view configuration' do
      Test::AppView.configuration.must_be :frozen?
    end

    it 'freezes view subclass configuration' do
      Test::AppViewLayout.configuration.must_be :frozen?
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
