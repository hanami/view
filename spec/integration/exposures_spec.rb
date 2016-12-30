RSpec.describe 'exposures' do
  let(:scope) { Struct.new(:title).new('dry-view rocks!') }

  it 'uses exposures to build view locals' do
    vc = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'users'
        config.formats = {html: :slim}
      end

      expose :users do |input|
        input.fetch(:users).map { |user|
          user.merge(name: user[:name].upcase)
        }
      end
    end.new

    users = [
      { name: 'Jane', email: 'jane@doe.org' },
      { name: 'Joe', email: 'joe@doe.org' }
    ]

    expect(vc.(users: users, scope: scope, locals: {subtitle: 'Users List'})).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><h2>Users List</h2><div class="users"><table><tbody><tr><td>JANE</td><td>jane@doe.org</td></tr><tr><td>JOE</td><td>joe@doe.org</td></tr></tbody></table></div></body></html>'
    )
  end

  it 'supports both blocks and instance methods as exposures' do
    vc = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'users'
        config.formats = {html: :slim}
      end

      expose :users

      private

      def users(input)
        input.fetch(:users).map { |user|
          user.merge(name: user[:name].upcase)
        }
      end
    end.new

    users = [
      { name: 'Jane', email: 'jane@doe.org' },
      { name: 'Joe', email: 'joe@doe.org' }
    ]

    expect(vc.(users: users, scope: scope, locals: {subtitle: 'Users List'})).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><h2>Users List</h2><div class="users"><table><tbody><tr><td>JANE</td><td>jane@doe.org</td></tr><tr><td>JOE</td><td>joe@doe.org</td></tr></tbody></table></div></body></html>'
    )
  end

  it 'allows exposures to depend on each other' do
    vc = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'users_with_count'
        config.formats = {html: :slim}
      end

      expose :users do |input|
        input.fetch(:users)
      end

      expose :users_count do |users|
        "#{users.length} users"
      end
    end.new

    users = [
      {name: 'Jane', email: 'jane@doe.org'},
      {name: 'Joe', email: 'joe@doe.org'}
    ]

    expect(vc.(users: users, scope: scope, locals: {subtitle: 'Users List'})).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><h2>Users List</h2><ul><li>Jane (jane@doe.org)</li><li>Joe (joe@doe.org)</li></ul><div class="count">2 users</div></body></html>'
    )
  end

  it 'allows exposures to be hidden from the view' do
    vc = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'users_with_count'
        config.formats = {html: :slim}
      end

      expose :prefix, to_view: false do
        "COUNT: "
      end

      expose :users do |input|
        input.fetch(:users)
      end

      expose :users_count do |prefix, users|
        "#{prefix}#{users.length} users"
      end
    end.new

    users = [
      {name: 'Jane', email: 'jane@doe.org'},
      {name: 'Joe', email: 'joe@doe.org'}
    ]

    input = {users: users, scope: scope, locals: {subtitle: 'Users List'}}

    expect(vc.(input)).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><h2>Users List</h2><ul><li>Jane (jane@doe.org)</li><li>Joe (joe@doe.org)</li></ul><div class="count">COUNT: 2 users</div></body></html>'
    )

    expect(vc.locals(input)).to include(:users, :users_count)
    expect(vc.locals(input)).not_to include(:prefix)
  end
end
