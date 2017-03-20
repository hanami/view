describe Hanami::View::Escape do
  before do
    path     = Pathname.new("#{FILE_FIXTURES_PATH}/users/show.html.erb")
    template = Hanami::View::Template.new(path, 'utf-8')

    @user = User.new(%(<script>alert('username')</script>))
    @book = Book.new(%(<script>alert('title')</script>))
    @view = Users::Show.new(template, user: @user, book: @book, code: %(<script>alert('code')</script>))
  end

  it 'escapes concrete method' do
    expect(@view.custom).to eq %(&lt;script&gt;alert(&apos;custom&apos;)&lt;&#x2F;script&gt;)
  end

  it 'escapes concrete methods with user input' do
    expect(@view.username).to eq %(&lt;script&gt;alert(&apos;username&apos;)&lt;&#x2F;script&gt;)
  end

  it 'escapes implicit methods' do
    expect(@view.code).to eq %(&lt;script&gt;alert(&apos;code&apos;)&lt;&#x2F;script&gt;)
  end

  it "doesn't escape concrete raw methods" do
    expect(@view.raw_username).to eq %(<script>alert('username')</script>)
  end

  it 'escapes objects' do
    expect(@view.book.title).to eq %(&lt;script&gt;alert(&apos;title&apos;)&lt;&#x2F;script&gt;)
  end

  it "doesn't interfer with other views" do
    expect(Users::Show.autoescape_methods).to eq({custom: true, username: true, raw_username: true, book: true, protected_username: true, private_username: true})
    expect(Users::Extra.autoescape_methods).to eq({username: true})
  end

  it "escapes custom rendering" do
    user = User.new('L')
    xml  = Users::Show.render(format: :xml, user: user)

    expect(xml).to eq %(&lt;username&gt;L&lt;&#x2F;username&gt;)
  end

  it "works with raw contents in custom rendering" do
    user = User.new('L')
    json = Users::Show.render(format: :json, user: user)

    expect(json).to eq %({"username":"L"})
  end

  it "does not alter the method visibility" do
    expect(Users::Show.private_instance_methods).to include(:private_username)
    expect(Users::Show.protected_instance_methods).to include(:protected_username)
    expect(Users::Show.public_instance_methods).to include(:raw_username)
  end
end
