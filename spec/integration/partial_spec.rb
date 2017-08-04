RSpec.describe 'Framework configuration' do
  it 'App1 can render a view containing one of its own partials' do
    rendered = App1::Views::Home::Index.render(format: :html)
    expect(rendered).to include 'app 1 partial'
  end

  it 'App2 can render a view containing one of its own partials' do
    rendered = App2::Views::Home::Index.render(format: :html)
    expect(rendered).to include 'app 2 partial'
  end

  it "App2 cannot render a view containing a partial from App1" do
    expect do
      App2::Views::Home::Show.render(format: :html)
    end.to raise_error(Hanami::View::MissingTemplateError)
  end
end
