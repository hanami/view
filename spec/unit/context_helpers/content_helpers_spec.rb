RSpec.describe Hanami::View::Context, "ContentHelpers" do
  let(:context) {
    Class.new(described_class) do
      include Hanami::View::ContextHelpers::ContentHelpers
    end.new
  }

  describe "#content_for" do
    context "no content set" do
      it "returns nil" do
        expect(context.content_for(:title)).to be nil
      end
    end

    context "content set" do
      before do
        context.content_for :title, "Hello World"
      end

      it "returns the content" do
        expect(context.content_for(:title)).to eq "Hello World"
      end
    end

    context "content set with a block" do
      before do
        context.content_for(:title) { "Hello Block" }
      end

      it "saves the content returned from the block" do
        expect(context.content_for(:title)).to eq "Hello Block"
      end
    end
  end
end
