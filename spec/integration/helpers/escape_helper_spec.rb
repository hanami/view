# frozen_string_literal: true

RSpec.describe "Escape helper" do
  before do
    @user   = User.new("MG", "http://freud.org", %(<span>hello</span>))
    @actual = Users::Show.render(format: :html, user: @user)
  end

  it "renders the title" do
    expect(@actual).to match(%(<h1>#{@user.name}</h1>))
  end

  it "renders the details" do
    expect(@actual).to match(%(<div id="details">\n<ul>\n<li>\n<a href="#{@user.website}" title="#{@user.name}'s website">website</a>\n</li>\n<li>#{@user.snippet}</li>\n</ul>\n</div>))
  end
end
