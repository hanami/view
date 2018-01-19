RSpec.describe 'Part / Decorated attributes' do
  let(:article_class) { Struct.new('Article', :title, :author, :comments, keyword_init: true) }
  let(:author_class) { Struct.new('Author', :name, keyword_init: true) }
  let(:comment_class) { Struct.new('Comment', :author, :body, keyword_init: true) }

  let(:article_part_class) {
    Class.new(Dry::View::Part) do
      decorate :author
      decorate :comments
    end
  }

  context 'using default decorator' do
    subject(:article_part) {
      article_part_class.new(
        name: :article,
        value: article,
      )
    }

    let(:article) {
      article_class.new(
        title: 'Hello world',
        author: author_class.new(name: 'Jane Doe'),
        comments: [
          comment_class.new(author: author_class.new(name: 'Sue Smith'), body: 'Great article')
        ]
      )
    }

    it 'decorates exposures with the standard Dry::View::Part class' do
      # byebug
      expect(article_part.author).to be_a Dry::View::Part
      # expect(article_part.comments[0]).to be_a Dry::View::Part
    end
  end
end
