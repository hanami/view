require 'test_helper'

describe Hanami::View do
  describe '.load!' do
    before do
      Hanami::View.unload!
      Hanami::View.class_eval do
        configure do
          root Pathname.new __dir__ + '/fixtures/templates'
        end
      end

      Hanami::View.load!
    end

    it 'partials must be included in the framework configuration registry but not copied to individual view configurations' do
      Hanami::View.configuration.partials.keys.must_include('shared/_sidebar')
      Articles::Show.configuration.partials.keys.wont_include('shared/_sidebar')
    end

    it 'ensures to reload view registry each time load is invoked' do
      CardDeck::View.load!
      old = CardDeck::Views::Home::Index.__send__(:registry).object_id
      CardDeck::View.load!
      current = CardDeck::Views::Home::Index.__send__(:registry).object_id

      current.wont_equal old
    end

    it 'ensures to reload layout registry each time load is invoked' do
      CardDeck::View.load!
      old = CardDeck::ApplicationLayout.__send__(:registry).object_id
      CardDeck::View.load!
      current = CardDeck::ApplicationLayout.__send__(:registry).object_id

      current.wont_equal old
    end

    # it 'freezes .layout for all the views' do
    #   AppView.layout.frozen?.must_equal true
    # end

    # it 'freezes .layout for subclasses' do
    #   AppViewLayout.layout.frozen?.must_equal true
    # end

    # it 'freezes .format for all the views with that declaration' do
    #   JsonRenderView.format.frozen?.must_equal true
    # end

    # it 'freezes .format for subclasses' do
    #   Articles::RssIndex.format.frozen?.must_equal true
    # end

    # it 'freezes .template' do
    #   Articles::Show.template.frozen?.must_equal true
    # end

    # it 'freezes .template for subclasses' do
    #   Articles::JsonShow.template.frozen?.must_equal true
    # end

    # it 'freezes .subclasses' do
    #   Articles::Index.subclasses.frozen?.must_equal true
    # end

    # it 'freezes .subclasses for subclasses' do
    #   Articles::AtomIndex.subclasses.frozen?.must_equal true
    # end

    # it 'freezes view .views' do
    #   Articles::Index.send(:views).frozen?.must_equal true
    # end

    # it 'freezes .views for subclasses' do
    #   Articles::RssIndex.send(:views).frozen?.must_equal true
    # end

    # it 'freezes .registry' do
    #   Articles::Index.send(:registry).frozen?.must_equal true
    # end

    # it 'freezes .registry for subclasses' do
    #   Articles::AtomIndex.send(:registry).frozen?.must_equal true
    # end

    # describe 'layouts' do
    #   it 'freezes .root' do
    #     ApplicationLayout.root.frozen?.must_equal true
    #   end

    #   it 'freezes .registry' do
    #     ApplicationLayout.send(:registry).frozen?.must_equal true
    #   end
    # end
  end
end
