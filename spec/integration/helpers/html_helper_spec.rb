# frozen_string_literal: true

RSpec.describe "HTML helper" do
  subject(:view) {
    Class.new(Hanami::View) do
      config.paths = TEMPLATES_PATH
      config.template = "books/show"

      expose :book

      expose :title_widget do
        html.div do
          h1 book.title
        end
      end
    end.new
  }

  let(:ctx) do
    Class.new(Hanami::View::Context) {
      include Hanami::Helpers
    }.new
  end

  let(:book) { Book.new(title: "The Work of Art in the Age of Mechanical Reproduction") }

  it "renders the generated html" do
    actual = view.(context: ctx, book: book).to_s
    expect(actual).to match("<div>\n<h1>The Work of Art in the Age of Mechanical Reproduction</h1>\n</div>")
  end

  xit "raises an error when referencing an unknown local variable" do
    expect do
      view.call
    end.to raise_error(NoMethodError)
  end
end
