require 'test_helper'

describe 'Escape' do
  before do
    path     = Pathname.new(__dir__ + '/fixtures/templates/users/show.html.erb')
    template = Hanami::View::Template.new(path, 'utf-8')

    @user = User.new(%(<script>alert('username')</script>))
    @book = Book.new(%(<script>alert('title')</script>))
    @view = Users::Show.new(template, user: @user, book: @book, code: %(<script>alert('code')</script>))
  end

  it 'escapes concrete method' do
    @view.custom.must_equal %(&lt;script&gt;alert(&apos;custom&apos;)&lt;&#x2F;script&gt;)
  end

  it 'escapes concrete methods with user input' do
    @view.username.must_equal %(&lt;script&gt;alert(&apos;username&apos;)&lt;&#x2F;script&gt;)
  end

  it 'escapes implicit methods' do
    @view.code.must_equal %(&lt;script&gt;alert(&apos;code&apos;)&lt;&#x2F;script&gt;)
  end

  it "doesn't escape concrete raw methods" do
    @view.raw_username.must_equal %(<script>alert('username')</script>)
  end

  it 'escapes objects' do
    @view.book.title.must_equal %(&lt;script&gt;alert(&apos;title&apos;)&lt;&#x2F;script&gt;)
  end

  it "doesn't interfer with other views" do
    Users::Show.autoescape_methods.must_equal({custom: true, username: true, raw_username: true, book: true})
    Users::Extra.autoescape_methods.must_equal({username: true})
  end

  it "escapes custom rendering" do
    user = User.new('L')
    xml  = Users::Show.render(format: :xml, user: user)

    xml.must_match %(&lt;username&gt;L&lt;&#x2F;username&gt;)
  end

  it "works with raw contents in custom rendering" do
    user = User.new('L')
    json = Users::Show.render(format: :json, user: user)

    json.must_match %({"username":"L"})
  end
end
