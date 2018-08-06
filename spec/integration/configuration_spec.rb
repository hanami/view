RSpec.describe 'Framework configuration' do
  it 'keeps separated copies of the configuration' do
    framework_configuration = Hanami::View.configuration
    card_configuration      = CardDeck::View.configuration

    expect(framework_configuration).to_not eq(card_configuration)
  end

  it 'sets a root path' do
    card_configuration = CardDeck::View.configuration
    expect(card_configuration.root).to eq(Pathname.new('spec/support/fixtures/templates/card_deck/app/templates').realpath)
  end

  it 'sets a layout' do
    card_configuration = CardDeck::View.configuration
    expect(card_configuration.layout).to eq(CardDeck::ApplicationLayout)
  end

  it 'allow views to inherit the layout' do
    view_configuration = CardDeck::Views::Home::Index.configuration
    expect(view_configuration.layout).to eq(CardDeck::ApplicationLayout)
  end

  it 'includes modules from configuration in views' do
    modules = CardDeck::Views::Home::Index.included_modules
    expect(modules).to include(::MyCustomModule)
    expect(modules).to include(::MyOtherCustomModule)
  end

  it 'includes modules from configuration in layouts' do
    modules = CardDeck::ApplicationLayout.included_modules
    expect(modules).to include(::MyCustomModule)
    expect(modules).to include(::MyOtherCustomModule)
  end

  it 'in a view disable a layout' do
    expect(CardDeck::Views::Home::RssIndex.layout).to eq Hanami::View::Rendering::NullLayout
  end

  it 'allow views to specify a layout'
  # TODO: move all the values into the configuration:
  #
  #   * format
  #   * layout
  #   * template
  #
  # TODO move all the inherit logic into configuration:
  #
  #   Instead of HelloWorldView.subclasses, use HelloWorldView.configuration.views
  #
  # This also helps to have an unified API to load the framework Configuration#load! vs
  # Hanami::View::Inheritable#load!
  #
  # it 'allow views to specify a layout' do
  #   view_configuration = CardDeck::Views::Home::JsonIndex.configuration
  #   expect(view_configuration.layout).to be_nil
  # end
end
