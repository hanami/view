RSpec.describe 'dry-view' do
  let(:view_class) do
    Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'users'
        config.formats = {html: :slim, txt: :erb}
      end
    end
  end

  let(:scope) do
    Struct.new(:title).new('dry-view rocks!')
  end

  it 'renders within a layout using provided scope' do
    view = view_class.new

    users = [
      { name: 'Jane', email: 'jane@doe.org' },
      { name: 'Joe', email: 'joe@doe.org' }
    ]

    expect(view.(scope: scope, locals: { subtitle: "Users List", users: users })).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><h2>Users List</h2><div class="users"><table><tbody><tr><td>Jane</td><td>jane@doe.org</td></tr><tr><td>Joe</td><td>joe@doe.org</td></tr></tbody></table></div></body></html>'
    )
  end

  it 'renders without a layout' do
    vc = Class.new(view_class) do
      configure do |config|
        config.layout = false
      end
    end.new

    users = [
      { name: 'Jane', email: 'jane@doe.org' },
      { name: 'Joe', email: 'joe@doe.org' }
    ]

    expect(vc.(scope: scope, locals: { subtitle: "Users List", users: users })).to eql(
      '<h2>Users List</h2><div class="users"><table><tbody><tr><td>Jane</td><td>jane@doe.org</td></tr><tr><td>Joe</td><td>joe@doe.org</td></tr></tbody></table></div>'
    )
  end

  it 'renders a view without locals' do
    vc = Class.new(view_class) do
      configure do |config|
        config.template = 'empty'
      end
    end.new

    expect(vc.(scope: scope, locals: {})).to eq(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><p>This is a view with no locals.</p></body></html>'
    )
  end

  it 'renders a view with an alternative format and engine' do
    view = view_class.new

    users = [
      { name: 'Jane', email: 'jane@doe.org' },
      { name: 'Joe', email: 'joe@doe.org' }
    ]

    expect(view.(scope: scope, locals: { subtitle: 'Users List', users: users }, format: 'txt').strip).to eql(
      "# dry-view rocks!\n\n## Users List\n\n* Jane (jane@doe.org)\n* Joe (joe@doe.org)"
    )
  end

  it 'renders a view with a template on another view path' do
    view = Class.new(view_class) do
      configure do |config|
        config.paths = [SPEC_ROOT.join('fixtures/templates_override')] + Array(config.paths)
      end
    end.new

    users = [
      { name: 'Jane', email: 'jane@doe.org' },
      { name: 'Joe', email: 'joe@doe.org' }
    ]

    expect(view.(scope: scope, locals: {subtitle: 'Users List', users: users})).to eq(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><h1>OVERRIDE</h1><h2>Users List</h2><div class="users"><table><tbody><tr><td>Jane</td><td>jane@doe.org</td></tr><tr><td>Joe</td><td>joe@doe.org</td></tr></tbody></table></div></body></html>'
    )
  end

  it 'renders a view that passes arguments to it parts' do
    view = Class.new(view_class) do
      configure do |config|
        config.template = 'parts_with_args'
      end
    end.new

    users = [
      { name: 'Jane', email: 'jane@doe.org' },
      { name: 'Joe', email: 'joe@doe.org' }
    ]

    expect(view.(scope: scope, locals: {users: users})).to eq(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><div class="users"><div class="box"><h2>Nombre</h2>Jane</div><div class="box"><h2>Nombre</h2>Joe</div></div></body></html>'
    )
  end

  describe 'inheritance' do
    let(:parent_view) do
      klass = Class.new(Dry::View::Controller)

      klass.setting :paths, SPEC_ROOT.join('fixtures/templates')
      klass.setting :layout, 'app'
      klass.setting :formats, {html: :slim}

      klass
    end

    let(:child_view) do
      Class.new(parent_view) do
        configure do |config|
          config.template = 'tasks'
        end
      end
    end

    it 'renders within a parent class layout using provided scope' do
      view = child_view.new

      expect(view.(scope: scope, locals: { tasks: [{ title: 'one' }, { title: 'two' }] })).to eql(
        '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><ol><li>one</li><li>two</li></ol></body></html>'
      )
    end
  end
end
