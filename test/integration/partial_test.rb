require 'test_helper'

describe 'Framework configuration' do
  it "App1 can render a view containing one of it's own partials" do
    rendered = App1::Views::Home::Index.render(format: :html)
    rendered.must_include 'app 1 partial'
  end

  it "App2 can render a view containing one of it's own partials" do
    rendered = App2::Views::Home::Index.render(format: :html)
    rendered.must_include 'app 2 partial'
  end

  it "App2 cannot render a view containing a partial from App1" do
    -> {
      App2::Views::Home::Show.render(format: :html)
    }.must_raise(Hanami::View::MissingTemplateError)
  end
end
