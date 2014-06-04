require 'test_helper'

describe Lotus::View do
  describe '.load!' do
    before do
      Lotus::View.load!
    end

    it 'freezes .root for all the views' do
      AppView.root.frozen?.must_equal true
    end

    it 'freezes .layout for all the views' do
      AppView.layout.frozen?.must_equal true
    end

    it 'freezes .layout for subclasses' do
      AppViewLayout.layout.frozen?.must_equal true
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

    describe 'layouts' do
      it 'freezes .root' do
        ApplicationLayout.root.frozen?.must_equal true
      end

      it 'freezes .registry' do
        ApplicationLayout.send(:registry).frozen?.must_equal true
      end
    end
  end
end
