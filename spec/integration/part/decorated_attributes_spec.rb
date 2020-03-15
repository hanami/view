# frozen_string_literal: true

require "dry/core/inflector"
require "hanami/view/scope_builder"

RSpec.describe "Part / Decorated attributes" do
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

  let(:author) {
    author_class.new(name: "Jane Doe")
  }

  let(:article) {
    article_class.new(
      title: "Hello world",
      author: author,
      comments: [
        comment_class.new(author: author_class.new(name: "Sue Smith"), body: "Great article")
      ]
    )
  }

  subject(:article_part) {
    article_part_class.new(
      name: :article,
      value: article,
      render_env: render_env
    )
  }

  let(:render_env) {
    Hanami::View::RenderEnvironment.new(
      renderer: Hanami::View::Renderer.new([Hanami::View::Path.new(FIXTURES_PATH)], format: :html),
      inflector: Dry::Inflector.new,
      context: Hanami::View::Context.new,
      scope_builder: Hanami::View::ScopeBuilder.new,
      part_builder: part_builder
    )
  }

  describe "using default part builder" do
    let(:part_builder) { Hanami::View::PartBuilder.new }

    describe "decorating without options" do
      describe "multiple declarations" do
        let(:article_part_class) {
          Class.new(Hanami::View::Part) do
            decorate :author
            decorate :comments
          end
        }

        it "decorates attributes with the standard Hanami::View::Part class" do
          expect(article_part.author).to be_a Hanami::View::Part
          expect(article_part.comments[0]).to be_a Hanami::View::Part
        end

        context "falsey values" do
          let(:author) { nil }

          it "does not decorate the attributes" do
            expect(article_part.author).to be_nil
          end
        end
      end

      describe "single declaration" do
        let(:article_part_class) {
          Class.new(Hanami::View::Part) do
            decorate :author, :comments
          end
        }

        it "decorates attributes with the standard Hanami::View::Part class" do
          expect(article_part.author).to be_a Hanami::View::Part
          expect(article_part.comments[0]).to be_a Hanami::View::Part
        end

        context "falsey values" do
          let(:author) { nil }

          it "does not decorate the attributes" do
            expect(article_part.author).to be_nil
          end
        end
      end
    end

    describe "decorating with part class specified" do
      before do
        module Test
          class AuthorPart < Hanami::View::Part
          end

          class CommentPart < Hanami::View::Part
          end
        end
      end

      let(:article_part_class) {
        Class.new(Hanami::View::Part) do
          decorate :author, as: Test::AuthorPart
          decorate :comments, as: Test::CommentPart
        end
      }

      it "deorates attributes with the specified part class" do
        expect(article_part.author).to be_a Test::AuthorPart
        expect(article_part.comments[0]).to be_a Test::CommentPart
      end

      context "falsey values" do
        let(:author) { nil }

        it "does not decorate the attributes" do
          expect(article_part.author).to be_nil
        end
      end
    end
  end

  describe "using custom part builder" do
    let(:article_part_class) {
      Class.new(Hanami::View::Part) do
        decorate :author
        decorate :comments
      end
    }

    let(:part_builder) {
      Class.new(Hanami::View::PartBuilder) do
        def part_class(name:, **options)
          part_name = Dry::Core::Inflector.camelize(name)

          begin
            Test.const_get(:"#{part_name}Part")
          rescue NameError
            super
          end
        end
      end.new
    }

    before do
      module Test
        class AuthorPart < Hanami::View::Part
        end

        class CommentPart < Hanami::View::Part
          decorate :author
        end
      end
    end

    it "deorates attributes using the custom part builder" do
      expect(article_part.author).to be_a Test::AuthorPart
      expect(article_part.comments[0]).to be_a Test::CommentPart
      expect(article_part.comments[0].author).to be_a Test::AuthorPart
    end

    context "falsey values" do
      let(:author) { nil }

      it "does not decorate the attributes" do
        expect(article_part.author).to be_nil
      end
    end
  end
end
