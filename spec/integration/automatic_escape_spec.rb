RSpec.describe 'Automatic escape' do
  before do
    @user     = User.new(%(<script>alert('username')</script>))
    @book     = Book.new(%(<script>alert('title')</script>))
    @rendered = Users::Show.render(format: :html, user: @user, book: @book, code: %(<script>alert('code')</script>))
  end

  it 'escapes concrete methods' do
    expect(@rendered).to include %(&lt;script&gt;alert(&apos;custom&apos;)&lt;&#x2F;script&gt;)
  end

  it 'escapes concrete methods with user input' do
    expect(@rendered).to include %(&lt;script&gt;alert(&apos;username&apos;)&lt;&#x2F;script&gt;)
  end

  it 'escapes implicit methods' do
    expect(@rendered).to include %(&lt;script&gt;alert(&apos;code&apos;)&lt;&#x2F;script&gt;)
  end

  it "doesn't escape concrete raw methods" do
    expect(@rendered).to include %(<div id="raw_username"><script>alert('username')</script></div>)
  end

  it 'escapes concrete methods in layout' do
    expect(@rendered).to include %(<span class="username">&lt;script&gt;alert(&apos;username&apos;)&lt;&#x2F;script&gt;</span>)
  end

  it 'escapes concrete helpers in layout' do
    expect(@rendered).to include %(<title>User: &lt;script&gt;alert(&apos;username&apos;)&lt;&#x2F;script&gt;</title>)
  end

  it 'escapes objects' do
    expect(@rendered).to include %(<div id="book">&lt;script&gt;alert(&apos;title&apos;)&lt;&#x2F;script&gt;</div>)
  end
end
