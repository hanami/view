RSpec.describe Hanami::View do
  include_context 'reload configuration'

  describe 'initializing' do
    before do
      @view = Class.new do
        include Hanami::View
      end

      @template = Hanami::View::Template.new(__dir__ + '/../../support/fixtures/templates/hello_world.html.erb')
    end

    it 'initializes view without keyword arguments' do
      expect(@view.new(@template).locals).to eq Hash[]
    end

    it 'initializes view with keyword arguments' do
      expect(@view.new(@template, hello: 'world').locals).to eq({hello: 'world'})
    end
  end

  describe '.load!' do
    it 'partials must be included in the framework configuration registry but not copied to individual view configurations' do
      expect(Hanami::View.configuration.partials.keys).to include('shared/_sidebar')
      expect(Articles::Show.configuration.partials.keys).to_not include('shared/_sidebar')
    end

    it 'ensures to reload view registry each time load is invoked' do
      CardDeck::View.load!
      old = CardDeck::Views::Home::Index.__send__(:registry).object_id
      CardDeck::View.load!
      current = CardDeck::Views::Home::Index.__send__(:registry).object_id

      expect(current).to_not eq old
    end

    it 'ensures to reload layout registry each time load is invoked' do
      CardDeck::View.load!
      old = CardDeck::ApplicationLayout.__send__(:registry).object_id
      CardDeck::View.load!
      current = CardDeck::ApplicationLayout.__send__(:registry).object_id

      expect(current).to_not eq old
    end

    # it 'freezes .layout for all the views' do
    #   expect(AppView.layout.frozen?).to eq true
    # end

    # it 'freezes .layout for subclasses' do
    #   expect(AppViewLayout.layout.frozen?).to eq true
    # end

    # it 'freezes .format for all the views with that declaration' do
    #   expect(JsonRenderView.format.frozen?).to eq true
    # end

    # it 'freezes .format for subclasses' do
    #   expect(Articles::RssIndex.format.frozen?).to eq true
    # end

    # it 'freezes .template' do
    #   expect(Articles::Show.template.frozen?).to eq true
    # end

    # it 'freezes .template for subclasses' do
    #   expect(Articles::JsonShow.template.frozen?).to eq true
    # end

    # it 'freezes .subclasses' do
    #   expect(Articles::Index.subclasses.frozen?).to eq true
    # end

    # it 'freezes .subclasses for subclasses' do
    #   expect(Articles::AtomIndex.subclasses.frozen?).to eq true
    # end

    # it 'freezes view .views' do
    #   expect(Articles::Index.send(:views).frozen?).to eq true
    # end

    # it 'freezes .views for subclasses' do
    #   expect(Articles::RssIndex.send(:views).frozen?).to eq true
    # end

    # it 'freezes .registry' do
    #   expect(Articles::Index.send(:registry).frozen?).to eq true
    # end

    # it 'freezes .registry for subclasses' do
    #   expect(Articles::AtomIndex.send(:registry).frozen?).to eq true
    # end

    # describe 'layouts' do
    #   it 'freezes .root' do
    #     expect(ApplicationLayout.root.frozen?).to eq true
    #   end

    #   it 'freezes .registry' do
    #     expect(ApplicationLayout.send(:registry).frozen?).to eq true
    #   end
    # end

  end

  describe 'rendering' do
    it 'renders a template' do
      expect(HelloWorldView.render(format: :html)).to include %(<h1>Hello, World!</h1>)
    end

    it 'renders a template with context binding' do
      expect(RenderView.render(format: :html, planet: 'Mars')).to include %(<h1>Hello, Mars!</h1>)
    end

    # See https://github.com/hanami/view/issues/76
    it 'renders a template with different encoding' do
      expect(EncodingView.render(format: :html)).to include %(Configuração)
    end

    # See https://github.com/hanami/view/issues/76
    it 'raises error when given encoding is not correct' do
      expect do
        Class.new do
          include Hanami::View
          configuration.default_encoding 'wrong'

          def self.name; 'EncodingView'; end
        end.render(format: :html)
      end.to raise_error(ArgumentError, "unknown encoding name - wrong")
    end

    it 'renders a template according to the declared format' do
      expect(JsonRenderView.render(format: :json, planet: 'Moon')).to include %("greet":"Hello, Moon!")
    end

    it 'renders a template according to the requested format' do
      articles = [ OpenStruct.new(title: 'Man on the Moon!') ]

      rendered = Articles::Index.render(format: :json, articles: articles)
      expect(rendered).to match %("title":"Man on the Moon!")

      rendered = Articles::Index.render(format: :html, articles: articles)
      expect(rendered).to match %(<h1>Man on the Moon!</h1>)
    end

    # this test was added to show that ../templates/members/articles/index.html.erb interferres with the normal behavior
    it 'renders the correct template when a subdirectory also exists' do
      articles = [ OpenStruct.new(title: 'Man on the Moon!') ]

      rendered = Articles::Index.render(format: :html, articles: articles)
      expect(rendered).not_to match %(<h1>Wrong Article Template</h1>)
      expect(rendered).to match %(<h1>Man on the Moon!</h1>)

      rendered = Members::Articles::Index.render(format: :html, articles: articles)
      expect(rendered).to match %(<h1>Wrong Article Template</h1>)
      expect(rendered).not_to match %(<h1>Man on the Moon!</h1>)
    end

    describe 'calling an action method from the template' do
      it 'can call with multiple arguments' do
        expect(RenderViewMethodWithArgs.render({format: :html})).to include %(<h1>Hello, earth!</h1>)
      end

      it 'will override Kernel methods' do
        expect(RenderViewMethodOverride.render({format: :html})).to include %(<h1>Hello, foo!</h1>)
      end

      it 'can call with block' do
        expect(RenderViewMethodWithBlock.render({format: :html})).to include %(<ul><li>thing 1</li><li>thing 2</li><li>thing 3</li></ul>)
      end
    end

    it 'binds given locals to the rendering context' do
      article = OpenStruct.new(title: 'Hello')

      rendered = Articles::Show.render(format: :html, article: article)
      expect(rendered).to match %(<h1>HELLO</h1>)
    end

    it 'renders a template from a subclass, if it is able to handle the requested format' do
      article = OpenStruct.new(title: 'Hello')

      rendered = Articles::Show.render(format: :json, article: article)
      expect(rendered).to match %("title":"olleh")
    end

    it 'raises an error when the template is missing' do
      article = OpenStruct.new(title: 'Ciao')

      expect do
        Articles::Show.render(format: :png, article: article)
      end.to raise_error(Hanami::View::MissingTemplateError)
    end

    it 'raises an error when the format is missing' do
      expect do
        HelloWorldView.render({})
      end.to raise_error(Hanami::View::MissingFormatError)
    end

    it 'renders different template, as specified by DSL' do
      article = OpenStruct.new(title: 'Bonjour')
      result  = OpenStruct.new(errors: {title: 'Title is required'})

      rendered = Articles::Create.render(format: :html, article: article, result: result)
      expect(rendered).to match %(<h1>New Article</h1>)
      expect(rendered).to match %(<h2>Errors</h2>)
    end

    it 'finds and renders template in nested directories' do
      rendered = NestedView.render(format: :html)
      expect(rendered).to match %(<h1>Nested</h1>)
    end

    it 'finds and renders partials in the directory of the view template parent directory' do
      rendered = Organisations::OrderTemplates::Action.render(format: :html)
      expect(rendered).to match %(Order Template Partial)
      expect(rendered).to match %(<div id="sidebar"></div>)

      rendered = Organisations::Action.render(format: :html)
      expect(rendered).to match %(Organisation Partial)
      expect(rendered).to match %(<div id="sidebar"></div>)
    end

    it 'decorates locals' do
      map = Map.new(['Rome', 'Cambridge'])

      rendered = Dashboard::Index.render(format: :html, map: map)
      expect(rendered).to match %(<h1>Map</h1>)
      expect(rendered).to match %(<h2>2 locations</h2>)
    end

    it 'safely ignores missing locals' do
      map = Map.new(['Rome', 'Cambridge'])

      rendered = Dashboard::Index.render(format: :html, map: map)
      expect(rendered).not_to match %(<h3>Annotations</h3>)
    end

    it 'uses optional locals, if present' do
      map         = Map.new(['Rome', 'Cambridge'])
      annotations = OpenStruct.new(written?: true)

      rendered = Dashboard::Index.render(format: :html, annotations: annotations, map: map)
      expect(rendered).to match %(<h3>Annotations</h3>)
    end

    it 'renders a partial' do
      article = OpenStruct.new(title: nil)

      rendered = Articles::New.render(format: :html, article: article)

      expect(rendered).to match %(<h1>New Article</h1>)
      expect(rendered).to match %(<input type="hidden" name="secret" value="23" />)
    end

    it 'raises an error when the partial template is missing' do
      expect do
        RenderViewWithMissingPartialTemplate.render(format: :html)
      end.to raise_error(Hanami::View::MissingTemplateError, "Can't find template 'shared/missing_template' for 'html' format.")
    end

    # @issue https://github.com/hanami/view/issues/3
    it 'renders a template within another template' do
      parent = OpenStruct.new(children: [], name: 'parent')
      child1 = OpenStruct.new(children: [], name: 'child1')
      child2 = OpenStruct.new(children: [], name: 'child2')

      parent.children.push(child1)
      parent.children.push(child2)

      rendered = Nodes::Parent.render(format: :html, node: parent)

      expect(rendered).to match %(<h1>parent</h1>)
      expect(rendered).to match %(<li>child1</li>)
      expect(rendered).to match %(<li>child2</li>)
    end

    it 'uses HAML engine' do
      person = OpenStruct.new(name: 'Luca')

      rendered = Contacts::Show.render(format: :html, person: person)
      expect(rendered).to match %(<h1>Luca</h1>)
      expect(rendered).to match %(<script type="text/javascript" src="/javascripts/contacts.js"></script>)
    end

    it 'uses Slim engine' do
      desk = OpenStruct.new(type: 'Standing')

      rendered = Desks::Show.render(format: :html, desk: desk)
      expect(rendered).to match %(<h1>Standing</h1>)
      expect(rendered).to match %(<script type="text/javascript" src="/javascripts/desks.js"></script>)
    end

    describe 'when without a template' do
      it 'renders from the custom rendering method' do
        song = OpenStruct.new(title: 'Song Two', url: '/song2.mp3')

        rendered = Songs::Show.render(format: :html, song: song)
        expect(rendered).to eq %(<audio src="/song2.mp3">Song Two</audio>)
      end

      it 'respond to all the formats' do
        rendered = Metrics::Index.render(format: :html)
        expect(rendered).to eq %(metrics)

        rendered = Metrics::Index.render(format: :json)
        expect(rendered).to eq %(metrics)
      end
    end

    describe 'layout' do
      it 'renders contents from layout' do
        articles = [ OpenStruct.new(title: 'A Wonderful Day!') ]

        rendered = Articles::Index.render(format: :html, articles: articles)
        expect(rendered).to match %(<h1>A Wonderful Day!</h1>)
        expect(rendered).to match %(<html>)
        expect(rendered).to match %(<title>Title: articles</title>)
      end

      it 'safely ignores missing locals' do
        articles = [ OpenStruct.new(title: 'A Wonderful Day!') ]

        rendered = Articles::Index.render(format: :html, articles: articles)
        expect(rendered).not_to match %(<h2>Your plan is overdue.</h2>)
      end

      it 'uses optional locals, if present' do
        articles = [ OpenStruct.new(title: 'A Wonderful Day!') ]
        plan     =   OpenStruct.new(overdue?: true)

        rendered = Articles::Index.render(format: :html, plan: plan, articles: articles)
        expect(rendered).to match %(<h2>Your plan is overdue.</h2>)
      end
    end
  end

  context 'unload' do
    before do
      Hanami::View.unload!
    end

    describe '.configuration' do
      before do
        class ConfigurationView
          include Hanami::View
        end

        class ConfigurationChildView < ConfigurationView
        end

        class ConfigurationLayout
          include Hanami::Layout
        end
      end

      after do
        Object.send(:remove_const, :ConfigurationChildView)
        Object.send(:remove_const, :ConfigurationView)
        Object.send(:remove_const, :ConfigurationLayout)
      end

      it 'exposes class configuration' do
        expect(Hanami::View.configuration).to be_kind_of(Hanami::View::Configuration)
      end

      it 'defaults root to the current dir' do
        expect(Hanami::View.configuration.root).to eq(Pathname.new('.').realpath)
      end

      it 'a view inherits the configuration from the framework' do
        expected = Hanami::View.configuration
        actual   = ConfigurationView.configuration

        expect(actual.root).to eq(expected.root)
      end

      it 'a view inherits the parent' do
        parent = ConfigurationView.configuration
        child  = ConfigurationChildView.configuration

        expect(child.root).to eq(parent.root)
        expect(child).to_not be(parent)
      end

      it "doesn't interfer with parent configuration" do
        parent = AppView.configuration
        child  = AppViewRoot.configuration

        expect(child.root).to_not eq(parent.root)

        expect(child).to_not eq(parent)
        expect(child).to_not be(parent)
      end

      it 'a view must be included in the framework configuration registry' do
        expect(Hanami::View.configuration.views).to include(ConfigurationView)
        expect(ConfigurationView.configuration.views).to_not include(ConfigurationView)
      end

      it 'a layout inheriths the configuration from the framework' do
        expected = Hanami::View.configuration
        actual   = ConfigurationLayout.configuration

        expect(actual.root).to eq(expected.root)
      end

      it 'a layout must be included in the framework configuration registry' do
        expect(Hanami::View.configuration.layouts).to include(ConfigurationLayout)
        expect(ConfigurationLayout.configuration.layouts).to_not include(ConfigurationView)
      end
    end

    describe '.configure' do
      it 'allows to configure the framework' do
        path = Pathname.new('.').join('spec/support/fixtures').realpath

        Hanami::View.class_eval do
          configure do
            root path
          end
        end

        expect(Hanami::View.configuration.root).to eq(path)
      end

      it 'allows to override one value' do
        Hanami::View.class_eval do
          configure do
            load_paths << 'spec/fixtures'
          end

          configure do
            load_paths << 'spec/fixtures/templates'
          end
        end

        configuration = Hanami::View.configuration

        expect(configuration.load_paths.send(:paths)).to include('spec/fixtures')
        expect(configuration.load_paths.send(:paths)).to include('spec/fixtures/templates')
      end
    end

    describe '.dupe' do
      before do
        Hanami::View.class_eval do
          configure do
            root '..'
          end
        end

        DuplicatedView = Hanami::View.dupe

        @framework_config  = Hanami::View.configuration
        @duplicated_config = DuplicatedView.configuration
      end

      after do
        Object.send(:remove_const, :DuplicatedView)
      end

      it 'creates a copy of self' do
        expect(@duplicated_config.root).to eq @framework_config.root
      end

      it 'creates a copy of self' do
        @duplicated_config.root('.')

        expect(@duplicated_config.root).to eq Pathname.new('.').realpath
        expect(@framework_config.root).to eq Pathname.new('..').realpath
      end
    end

    describe '.duplicate' do
      before do
        Hanami::View.configure { layout :application }

        module Duplicated
          View = Hanami::View.duplicate(self)
        end

        module DuplicatedCustom
          View = Hanami::View.duplicate(self, 'Viewz')
        end

        module DuplicatedWithoutNamespace
          View = Hanami::View.duplicate(self, nil)
        end

        module DuplicatedConfigure
          View = Hanami::View.duplicate(self) do
            layout :app
          end

          module Views
            class AppLayout
              include DuplicatedConfigure::Layout
            end
          end
        end
      end

      after do
        Hanami::View.configuration.reset!

        Object.send(:remove_const, :Duplicated)
        Object.send(:remove_const, :DuplicatedCustom)
        Object.send(:remove_const, :DuplicatedWithoutNamespace)
        Object.send(:remove_const, :DuplicatedConfigure)
      end

      it 'duplicates the configuration of the framework' do
        actual   = Duplicated::View.configuration
        expected = Hanami::View.configuration

        expect(actual.layout).to eq(expected.layout)
      end

      it 'generates a namespace for views' do
        expect(defined?(Duplicated::Views)).to be_truthy, lambda { 'Duplicated::Views expected' }
      end

      it 'generates a custom namespace for views' do
        expect(defined?(DuplicatedCustom::Viewz)).to be_truthy, lambda { 'DuplicatedCustom::Viewz expected' }
      end

      it 'does not create a custom namespace for views' do
        expect(defined?(DuplicatedWithoutNamespace::Views)).to_not be_truthy, lambda { "DuplicatedWithoutNamespace::Views wasn't expected" }
      end

      it 'assigns correct namespace to the configuration when the namespace argument is nil' do
        expect(DuplicatedWithoutNamespace::View.configuration.namespace).to eq 'DuplicatedWithoutNamespace'
      end

      it 'duplicates Layout' do
        expect(defined?(Duplicated::Layout)).to be_truthy, lambda { 'Duplicated::Layout expected' }
      end

      it 'duplicates Presenter' do
        expect(defined?(Duplicated::Presenter)).to be_truthy, lambda { 'Duplicated::Presenter expected' }
      end

      it 'optionally accepts a block to configure the generated module' do
        expected = DuplicatedConfigure::Views::AppLayout
        expect(DuplicatedConfigure::View.configuration.layout).to eq expected
      end
    end

    describe 'global layout' do
      before do
        Hanami::View.class_eval do
          configure do
            layout :application
          end
        end

        class ViewWithInheritedLayout
          include Hanami::View
        end
      end

      after do
        Object.send(:remove_const, :ViewWithInheritedLayout)
      end

      it 'sets global layout' do
        expect(ViewWithInheritedLayout.layout).to eq ApplicationLayout
      end
    end
  end

end

