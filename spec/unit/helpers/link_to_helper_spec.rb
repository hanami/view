# frozen_string_literal: true

RSpec.describe Hanami::Helpers::LinkToHelper do
  let(:view) { LinkTo.new }

  it "escapes href" do
    expect(view.link_to_evil_url.to_s).to eq(%(<a href="fo%3Co%3Ebar">content</a>))
  end

  it "returns a link to posts" do
    expect(view.link_to_posts.to_s).to eq(%(<a href="/posts/">Posts</a>))
  end

  it "returns a link to a post" do
    expect(view.link_to_post.to_s).to eq(%(<a href="/post/1">Post</a>))
  end

  it "returns a link with a class" do
    expect(view.link_to_with_class.to_s).to eq(%(<a class="first" href="/posts/">Post</a>))
  end

  it "returns a link with id" do
    expect(view.link_to_with_id.to_s).to eq(%(<a id="posts__link" href="/posts/">Post</a>))
  end

  it "returns a link relative link" do
    expect(view.link_to_relative_posts.to_s).to eq(%(<a href="posts">Posts</a>))
  end

  it "returns a link with html content" do
    expect(view.link_to_with_html_content.to_s).to eq(%(<a href="/posts/"><strong>Post</strong></a>))
  end

  it "returns a link with html content, id and class" do
    expect(view.link_to_with_html_content_id_and_class.to_s).to eq(%(<a id="posts__link" class="first" href="/posts/"><strong>Post</strong></a>))
  end

  it "raises an exception link with content and html content" do
    expect { view.link_to_with_content_and_html_content }.to raise_error(ArgumentError)
  end

  it "raises an exception when link with content, html content, id and class" do
    expect { view.link_to_with_content_html_content_id_and_class }.to raise_error(ArgumentError)
  end

  it "raises an exception when have not arguments" do
    expect { view.link_to_without_args }.to raise_error(ArgumentError)
  end

  it "raises an exception when have not arguments and empty block" do
    expect { view.link_to_without_args_and_empty_block }.to raise_error(ArgumentError)
  end

  it "raises an exception when have only content" do
    expect { view.link_to_with_only_content }.to raise_error(ArgumentError)
  end
end
