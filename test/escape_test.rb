require 'test_helper'

describe 'Escape' do
  before do
    path     = Pathname.new(__dir__ + '/fixtures/templates/users/show.html.erb')
    template = Lotus::View::Template.new(path)

    @user = User.new(%(<script>alert('username')</script>))
    @view = Users::Show.new(template, user: @user, code: %(<script>alert('code')</script>))
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

  it "doesn't interfer with other views" do
    Users::Show.autoescape_methods.must_equal({custom: true, username: true, raw_username: true})
    Users::Extra.autoescape_methods.must_equal({username: true})
  end
end
