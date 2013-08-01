require 'test_helper'

describe Lotus::View do
  describe '.load!' do
    before do
      # Lotus::View.load! is invoked as last statement of `test/test_helper.rb`.
    end

    it 'freezes .root' do
      Lotus::View.root.frozen?.must_equal true
    end

    it 'freezes .root for all the views' do
      AppView.root.frozen?.must_equal true
    end

    it 'freezes .views' do
      Lotus::View.views.frozen?.must_equal true
    end

    it 'freezes .format for all the views with that declaration' do
      JsonRenderView.format.frozen?.must_equal true
    end

    it 'freezes .format for subclasses' do
      Articles::RssIndex.format.frozen?.must_equal true
    end

    it 'freezes .template' do
      Articles::Show.template.frozen?.must_equal true
    end

    it 'freezes .template for subclasses' do
      Articles::JsonShow.template.frozen?.must_equal true
    end

    it 'freezes .subclasses' do
      Articles::Index.subclasses.frozen?.must_equal true
    end

    it 'freezes .subclasses for subclasses' do
      Articles::AtomIndex.subclasses.frozen?.must_equal true
    end

    it 'freezes view .views' do
      Articles::Index.send(:views).frozen?.must_equal true
    end

    it 'freezes .views for subclasses' do
      Articles::RssIndex.send(:views).frozen?.must_equal true
    end

    it 'freezes .registry' do
      Articles::Index.send(:registry).frozen?.must_equal true
    end

    it 'freezes .registry for subclasses' do
      Articles::AtomIndex.send(:registry).frozen?.must_equal true
    end
  end
end
