RSpec.describe 'exposures' do
  let(:context) { Struct.new(:title, :assets).new('dry-view rocks!', -> input { "#{input}.jpg" }) }

  it 'uses exposures with blocks to build view locals' do
    vc = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'users'
        config.default_format = :html
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

    expect(vc.(users: users, context: context)).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><div class="users"><table><tbody><tr><td>JANE</td><td>jane@doe.org</td></tr><tr><td>JOE</td><td>joe@doe.org</td></tr></tbody></table></div><img src="mindblown.jpg" /></body></html>'
    )
  end

  it 'gives the exposure blocks access to the view controller instance' do
    vc = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'users'
        config.default_format = :html
      end

      attr_reader :prefix

      def initialize
        super
        @prefix = "My friend "
      end

      expose :users do |input|
        input.fetch(:users).map { |user|
          user.merge(name: prefix + user[:name])
        }
      end
    end.new

    users = [
      { name: 'Jane', email: 'jane@doe.org' },
      { name: 'Joe', email: 'joe@doe.org' }
    ]

    expect(vc.(users: users, context: context)).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><div class="users"><table><tbody><tr><td>My friend Jane</td><td>jane@doe.org</td></tr><tr><td>My friend Joe</td><td>joe@doe.org</td></tr></tbody></table></div><img src="mindblown.jpg" /></body></html>'
    )
  end

  it 'supports instance methods as exposures' do
    vc = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'users'
        config.default_format = :html
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

    expect(vc.(users: users, context: context)).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><div class="users"><table><tbody><tr><td>JANE</td><td>jane@doe.org</td></tr><tr><td>JOE</td><td>joe@doe.org</td></tr></tbody></table></div><img src="mindblown.jpg" /></body></html>'
    )
  end

  it 'passes matching input data if no proc or instance method is available' do
    vc = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'users'
        config.default_format = :html
      end

      expose :users
    end.new

    users = [
      { name: 'Jane', email: 'jane@doe.org' },
      { name: 'Joe', email: 'joe@doe.org' }
    ]

    expect(vc.(users: users, context: context)).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><div class="users"><table><tbody><tr><td>Jane</td><td>jane@doe.org</td></tr><tr><td>Joe</td><td>joe@doe.org</td></tr></tbody></table></div><img src="mindblown.jpg" /></body></html>'
    )
  end

  it 'allows exposures to depend on each other' do
    vc = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'users_with_count'
        config.default_format = :html
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

    expect(vc.(users: users, context: context)).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><ul><li>Jane (jane@doe.org)</li><li>Joe (joe@doe.org)</li></ul><div class="count">2 users</div></body></html>'
    )
  end

  it 'supports defining multiple exposures at once' do
    vc = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'users_with_count'
        config.default_format = :html
      end

      expose :users, :users_count

      private

      def users(input)
        input.fetch(:users)
      end

      def users_count(users)
        "#{users.length} users"
      end
    end.new

    users = [
      {name: 'Jane', email: 'jane@doe.org'},
      {name: 'Joe', email: 'joe@doe.org'}
    ]

    expect(vc.(users: users, context: context)).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><ul><li>Jane (jane@doe.org)</li><li>Joe (joe@doe.org)</li></ul><div class="count">2 users</div></body></html>'
    )
  end

  it 'allows exposures to be hidden from the view' do
    vc = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'users_with_count'
        config.default_format = :html
      end

      private_expose :prefix do
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

    input = {users: users, context: context}

    expect(vc.(input)).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><ul><li>Jane (jane@doe.org)</li><li>Joe (joe@doe.org)</li></ul><div class="count">COUNT: 2 users</div></body></html>'
    )

    expect(vc.locals(input)).to include(:users, :users_count)
    expect(vc.locals(input)).not_to include(:prefix)
  end
end
