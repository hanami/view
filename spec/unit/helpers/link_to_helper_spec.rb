# frozen_string_literal: true

require "hanami/view/helpers/link_to_helper"

RSpec.describe Hanami::View::Helpers::LinkToHelper, "#link_to" do
  subject(:obj) {
    Class.new {
      include Hanami::View::Helpers::LinkToHelper
    }.new
  }

  def h(&block)
    obj.instance_eval(&block).to_s
  end

  it "escapes href" do
    expect(h { link_to("content", "fo<o>bar") }).to eq %(<a href="fo%3Co%3Ebar">content</a>)
  end

  it "returns a link" do
    expect(h { link_to("Posts", "/posts") }).to eq %(<a href="/posts">Posts</a>)
  end

  it "returns a link with a class" do
    expect(h { link_to("Post", "/posts", class: "first") })
      .to eq %(<a class="first" href="/posts">Post</a>)
  end

  it "returns a link with id" do
    expect(h { link_to("Post", "/posts", id: "posts__link") })
      .to eq %(<a id="posts__link" href="/posts">Post</a>)
  end

  it "returns a link relative link" do
    expect(h { link_to("Posts", "posts") }).to eq %(<a href="posts">Posts</a>)
  end

  it "returns a link with html content" do
    expect(h {
      link_to("/posts") do
        strong "Post"
      end
    }).to eq %(<a href="/posts"><strong>Post</strong></a>)
  end

  it "returns a link with html content, id and class" do
    expect(h {
      link_to("/posts", id: "posts__link", class: "first") do
        strong "Post"
      end
    }).to eq %(<a id="posts__link" class="first" href="/posts"><strong>Post</strong></a>)
  end

  it "raises an exception link with content and html content" do
    expect { h {
      link_to("Posts", "/posts") do
        strong "Posts"
      end
    } }.to raise_error(ArgumentError)
  end

  it "raises an exception when link with content, html content, id and class" do
    expect { h {
      link_to("Post", "/posts", id: "posts__link", class: "first") do
        strong "Post"
      end
    } }.to raise_error(ArgumentError)
  end

  it "raises an exception when have not arguments" do
    expect { h { link_to } }.to raise_error(ArgumentError)
  end

  it "raises an exception when have not arguments and empty block" do
    expect { h {
      link_to do
        # Block left intentionally blank
      end
    } }.to raise_error(ArgumentError)
  end

  it "raises an exception when have only content" do
    expect { h { link_to "Post" } }.to raise_error(ArgumentError)
  end
end
