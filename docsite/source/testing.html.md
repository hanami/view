---
title: Testing
layout: gem-single
name: dry-view
---

dry-view is designed to encourage better testing of your views, with every component designed to support unit testing, in full isolation. This means you can test your views at whatever level of granularity makes sense for you, all the while maintaining a responsive test-driven development cycle.

## Testing views

To test a view object in full, initialize it, passing in any [dependencies](/gems/dry-view/injecting-dependencies/) it requires. Provide test doubles for these if you want to simulate certain conditions. Then you can call the view and express the behavior you desire for its rendered output string.

Given this view:

```ruby
class ArticleView < Dry::View
  config.template = "article"

  attr_reader :repo

  def initialize(repo:)
    @repo = repo
  end

  expose :article do |slug:|
    repo.by_slug(slug)
  end
end
```

A test could look like this:

```ruby
RSpec.describe ArticleView do
  subject(:view) { described_class.new(repo: repo) }

  let(:repo) { double(:repo) }
  let(:article) { double(:article, title: "Hello World") }

  before do
    allow(repo).to receive(:by_slug).with("hello-world").and_return article
  end

  describe "#call" do
    subject(:rendered) { view.call(slug: "hello-world") }

    it "renders the article details" do
      expect(rendered.to_s).to include("<h1>Hello World</h1>")
    end
  end
end
```

## Testing exposures

If you'd like to test a view's [exposures](/gems/dry-view/exposures/) directly, you can access them after calling the view:

```ruby
RSpec.describe ArticleView do
  subject(:view) { described_class.new(repo: repo) }

  let(:repo) { double(:repo) }
  let(:article) { double(:article, title: "Hello World") }

  before do
    allow(repo).to receive(:by_slug).with("hello-world").and_return article
  end

  describe "exposures" do
    subject(:rendered) { view.call(slug: "hello-world") }

    it "renders the article details" do
      expect(rendered[:article].title).to eq "Hello World"
    end
  end
end
```

## Testing simple part behavior

To test simple [part](/gems/dry-view/parts/) behavior, initialize a part and make your expectations against its methods:

```ruby
module Parts
  class Article < Dry::View::Part
    def byline
      "By #{author_name}"
    end
  end
end

RSpec.describe(Parts::Article) do
  subject(:part) { described_class.new(value: article) }
  let(:article) { double(:article, author_name: "Jane Doe") }

  describe "#byline" do
    it "includes the author name" do
      expect(part.byline).to eq "By Jane Doe"
    end
  end
end
```

## Testing part behavior requiring a render environment

To test [part](/gems/dry-view/parts/) behavior that [renders partials](/gems/dry-view/templates/) or accesses the [context](/gems/dry-view/context/), the part will need to be initialized with a name and _render environment_. You can get a render environment from a related view class via its `.template_env`:

```ruby
class ArticleView < Dry::View
  config.template = "article"
  config.part_namespace = Parts
  # ...
end

module Parts
  class Article < Dry::View::Part
    def author_details_html
      render(:author_details, author: author)
    end
  end
end

RSpec.describe(Parts::Article) do
  subject(:part) {
    described_class.new(
      value: article,
      name: :article,
      render_env: ArticleView.template_env,
    )
  }

  let(:article) { double(:article, author: double(:author, name: "Jane Doe")) }

  describe "#author_details_html" do
    it "includes author details" do
      html = part.author_details_html

      expect(html).to include "Jane Doe"
    end
  end
end
```
