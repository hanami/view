RSpec.describe 'Part / Decorated attributes' do
  let(:article_class) {
    Class.new do
      attr_reader :title, :author, :comments

      def initialize(title:, author:, comments:)
        @title = title
        @author = author
        @comments = comments
      end
    end
  }

  let(:author_class) {
    Class.new do
      attr_reader :name

      def initialize(name:)
        @name = name
      end
    end
  }

  let(:comment_class) {
    Class.new do
      attr_reader :author, :body

      def initialize(author:, body:)
        @author = author
        @body = body
      end
    end
  }

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
