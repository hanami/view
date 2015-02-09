require 'test_helper'

describe 'Automatic escape' do
  before do
    @user     = User.new(%(<script>alert('username')</script>))
    @rendered = Users::Show.render(format: :html, user: @user, code: %(<script>alert('code')</script>))
  end

  it 'escapes concrete methods' do
    @rendered.must_match %(&lt;script&gt;alert(&apos;custom&apos;)&lt;&#x2F;script&gt;)
  end

  it 'escapes concrete methods with user input' do
    @rendered.must_match %(&lt;script&gt;alert(&apos;username&apos;)&lt;&#x2F;script&gt;)
  end

  it 'escapes implicit methods' do
    @rendered.must_match %(&lt;script&gt;alert(&apos;code&apos;)&lt;&#x2F;script&gt;)
  end

  it "doesn't escape concrete raw methods" do
    @rendered.must_match %(<script>alert('username')</script>)
  end

  it 'escapes concrete methods in layout' do
    @rendered.must_match %(<span class="username">&lt;script&gt;alert(&apos;username&apos;)&lt;&#x2F;script&gt;</span>)
  end

  it 'escapes concrete helpers in layout' do
    @rendered.must_match %(<title>User: &lt;script&gt;alert(&apos;username&apos;)&lt;&#x2F;script&gt;</title>)
  end
end
