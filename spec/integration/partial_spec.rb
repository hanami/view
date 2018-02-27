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

  it "DeepPartials can render partials with same locals and doesn't override the outer local" do
    rendered = DeepPartials::Views::Home::Index.render(format: :html, name: 'Outer')
    expect(rendered).to eq("View before, Outer\npartial before, Inner\nother partial, More Inner\npartial after, Inner\nView after, Outer\n")
  end

  it "App3 can render partials using the locals in each scope" do
    rendered = App3::Views::Home::Index.render(format: :html, name: 'name')
    expect(rendered).to eq("View before, View name\nimplicit partial, View name\nother partial, View name\ndeep partial, View name\nexplicit partial, View partial\nother partial, View partial\ndeep partial, View partial\nView after, View name\n")
  end
end
