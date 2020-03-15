# frozen_string_literal: true

RSpec.describe "Testing / parts" do
  let(:part_class) {
    Class.new(Hanami::View::Part) do
    end
  }

  specify "Parts can be unit tested without name or rendering (for testing methods that don't require them)" do
    part_class = Class.new(Hanami::View::Part) do
      def breaking_news_title
        title + "!"
      end
    end

    article = Struct.new(:title).new("Giant Hand Threatens Beach City")

    article_part = part_class.new(value: article)

    expect(article_part.breaking_news_title).to eq "Giant Hand Threatens Beach City!"
  end

  specify "Parts can be unit tested with a rendering from a view class" do
    view_class = Class.new(Hanami::View) do
      config.paths = FIXTURES_PATH.join("integration/testing")
      config.template = "view"
    end

    part_class = Class.new(Hanami::View::Part) do
      def feature_box
        render(:feature_box)
      end
    end

    article = Struct.new(:title).new("A Guide to Beach City Funland")

    article_part = part_class.new(
      name: :article,
      value: article,
      render_env: view_class.template_env
    )

    expect(article_part.feature_box).to eq %(
      <div class="feature-article"><h1>A Guide to Beach City Funland</h1></div>
    ).strip
  end
end
