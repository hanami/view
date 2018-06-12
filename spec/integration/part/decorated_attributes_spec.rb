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

  let (:author) {
    author_class.new(name: 'Jane Doe')
  }

  let(:article) {
    article_class.new(
      title: 'Hello world',
      author: author,
      comments: [
        comment_class.new(author: author_class.new(name: 'Sue Smith'), body: 'Great article')
      ]
    )
  }

  describe 'using default decorator' do
    subject(:article_part) {
      article_part_class.new(
        name: :article,
        value: article,
      )
    }

    describe 'decorating without options' do
      describe 'multiple declarations' do
        let(:article_part_class) {
          Class.new(Dry::View::Part) do
            decorate :author
            decorate :comments
          end
        }

        it 'decorates exposures with the standard Dry::View::Part class' do
          expect(article_part.author).to be_a Dry::View::Part
          expect(article_part.comments[0]).to be_a Dry::View::Part
        end

        context 'falsey values' do
          let(:author) { nil }

          it 'does not decorate the attributes' do
            expect(article_part.author).to be_nil
          end
        end
      end

      describe 'single declaration' do
        let(:article_part_class) {
          Class.new(Dry::View::Part) do
            decorate :author, :comments
          end
        }

        it 'decorates exposures with the standard Dry::View::Part class' do
          expect(article_part.author).to be_a Dry::View::Part
          expect(article_part.comments[0]).to be_a Dry::View::Part
        end

        context 'falsey values' do
          let(:author) { nil }

          it 'does not decorate the attributes' do
            expect(article_part.author).to be_nil
          end
        end
      end
    end

    describe 'decorating with part class specified' do
      before do
        module Test
          class AuthorPart < Dry::View::Part
          end

          class CommentPart < Dry::View::Part
          end
        end
      end

      let(:article_part_class) {
        Class.new(Dry::View::Part) do
          decorate :author, as: Test::AuthorPart
          decorate :comments, as: Test::CommentPart
        end
      }

      it 'deorates exposures with the specified part class' do
        expect(article_part.author).to be_a Test::AuthorPart
        expect(article_part.comments[0]).to be_a Test::CommentPart
      end

      context 'falsey values' do
        let(:author) { nil }

        it 'does not decorate the attributes' do
          expect(article_part.author).to be_nil
        end
      end
    end
  end

  describe 'using custom decorator' do
    let(:article_part_class) {
        Class.new(Dry::View::Part) do
          decorate :author
          decorate :comments
        end
      }

    subject(:article_part) {
      article_part_class.new(
        name: :article,
        value: article,
        decorator: decorator,
      )
    }

    let(:decorator) {
      Class.new(Dry::View::Decorator) do
        def part_class(name, value, **options)
          if !options.key?(:as)
            part_name = Dry::Core::Inflector.camelize(name)
            begin
              Test.const_get(:"#{part_name}Part")
            rescue NameError
              super
            end
          else
            super
          end
        end
      end.new
    }

    before do
      module Test
        class AuthorPart < Dry::View::Part
        end

        class CommentPart < Dry::View::Part
          decorate :author
        end
      end
    end

    it 'deorates exposures using the custom decorator' do
      expect(article_part.author).to be_a Test::AuthorPart
      expect(article_part.comments[0]).to be_a Test::CommentPart
      expect(article_part.comments[0].author).to be_a Test::AuthorPart
    end

    context 'falsey values' do
      let(:author) { nil }

      it 'does not decorate the attributes' do
        expect(article_part.author).to be_nil
      end
    end
  end
end
