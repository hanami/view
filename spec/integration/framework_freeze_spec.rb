# frozen_string_literal: true

RSpec.describe "Framework freeze" do
  describe "Hanami::View" do
    before do
      Hanami::View.unload!
      Hanami::View.load!
    end

    it "freezes framework configuration" do
      expect(Hanami::View.configuration).to be_frozen
    end

    it "freezes view configuration" do
      expect(AppView.configuration).to be_frozen
    end

    it "freezes view subclass configuration" do
      expect(AppViewLayout.configuration).to be_frozen
    end

    it "freezes layout configuration" do
      expect(ApplicationLayout.configuration).to be_frozen
    end
  end

  describe "duplicated framework" do
    before do
      Store::View.unload!
      Store::View.load!
    end

    it "freezes framework configuration" do
      expect(Store::View.configuration).to be_frozen
    end

    it "freezes view configuration" do
      expect(Store::Views::Home::Index.configuration).to be_frozen
    end

    it "freezes view subclass configuration" do
      expect(Store::Views::Home::JsonIndex.configuration).to be_frozen
    end

    it "freezes layout configuration" do
      expect(Store::Views::StoreLayout.configuration).to be_frozen
    end
  end
end
