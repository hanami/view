require 'dry/view/controller'
require 'dry/view/part'

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

      expose :users do |users:|
        users.map { |user|
          user.merge(name: user[:name].upcase)
        }
      end
    end.new

    users = [
      { name: 'Jane', email: 'jane@doe.org' },
      { name: 'Joe', email: 'joe@doe.org' }
    ]

    expect(vc.(users: users, context: context).to_s).to eql(
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

      expose :users do |users:|
        users.map { |user|
          user.merge(name: prefix + user[:name])
        }
      end
    end.new

    users = [
      { name: 'Jane', email: 'jane@doe.org' },
      { name: 'Joe', email: 'joe@doe.org' }
    ]

    expect(vc.(users: users, context: context).to_s).to eql(
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

      def users(users:)
        users.map { |user|
          user.merge(name: user[:name].upcase)
        }
      end
    end.new

    users = [
      { name: 'Jane', email: 'jane@doe.org' },
      { name: 'Joe', email: 'joe@doe.org' }
    ]

    expect(vc.(users: users, context: context).to_s).to eql(
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

    expect(vc.(users: users, context: context).to_s).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><div class="users"><table><tbody><tr><td>Jane</td><td>jane@doe.org</td></tr><tr><td>Joe</td><td>joe@doe.org</td></tr></tbody></table></div><img src="mindblown.jpg" /></body></html>'
    )
  end

  it 'using default values' do
    vc = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'users'
        config.default_format = :html
      end

      expose :users, default: [{name: 'John', email: 'john@william.org'}]
    end.new

    expect(vc.(context: context).to_s).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><div class="users"><table><tbody><tr><td>John</td><td>john@william.org</td></tr></tbody></table></div><img src="mindblown.jpg" /></body></html>'
    )
  end

  it 'having default values but passing nil as value for exposure' do
    vc = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'greeting'
        config.default_format = :html
      end

      expose :greeting, default: 'Hello Dry-rb'
    end.new

    expect(vc.(greeting: nil, context: context).to_s).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><p></p></body></html>'
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

      expose :users

      expose :users_count do |users|
        "#{users.length} users"
      end
    end.new

    users = [
      {name: 'Jane', email: 'jane@doe.org'},
      {name: 'Joe', email: 'joe@doe.org'}
    ]

    expect(vc.(users: users, context: context).to_s).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><ul><li>Jane (jane@doe.org)</li><li>Joe (joe@doe.org)</li></ul><div class="count">2 users</div></body></html>'
    )
  end

  it 'wraps exposures in view parts before they are supplied as dependencies' do
    module Test
      class UserPart < Dry::View::Part
        def display_name
          "User: #{value[:name]}"
        end
      end
    end

    vc = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'users_with_count'
        config.default_format = :html
      end

      expose :users, as: Test::UserPart

      expose :users_count do |users|
        "#{users.length} users"
      end

      expose :article do |users|
        "Great article from #{users.first.display_name}"
      end
    end.new

    users = [
      {name: 'Jane', email: 'jane@doe.org'},
      {name: 'Joe', email: 'joe@doe.org'}
    ]

    rendered = vc.(users: users, context: context)

    expect(rendered[:users]).to be_a(Dry::View::Part)

    expect(rendered[:users][0]).to be_a(Test::UserPart)
    expect(rendered[:users][0].value).to eq(name: 'Jane', email: 'jane@doe.org')

    expect(rendered[:article]).to be_a(Dry::View::Part)
    expect(rendered[:article].to_s).to eq "Great article from User: Jane"
  end

  it 'allows exposures to depend on each other while still using keywords args to access input data' do
    vc = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'greeting'
        config.default_format = :html
      end

      expose :greeting do |prefix, greeting:|
        "#{prefix} #{greeting}"
      end

      expose :prefix do
        'Hello'
      end
    end.new

    expect(vc.(greeting: 'From dry-view internals', context: context).to_s).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><p>Hello From dry-view internals</p></body></html>'
    )
  end



  it 'supports default values for keyword arguments' do
    vc = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'greeting'
        config.default_format = :html
      end

      expose :greeting do |prefix, greeting: 'From the defaults'|
        "#{prefix} #{greeting}"
      end

      expose :prefix do
        'Hello'
      end
    end.new

    expect(vc.(context: context).to_s).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><p>Hello From the defaults</p></body></html>'
    )
  end

  it 'only passes keywords arguments that are needed in the block and allows for default values' do
    vc = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'edit'
        config.default_format = :html
      end

      expose :pretty_id do |id:|
        "Beautiful #{id}"
      end

      expose :errors do |errors: []|
        errors
      end
    end.new

    expect(vc.(id: 1, context: context).to_s).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><h1>Edit</h1><p>No Errors</p><p>Beautiful 1</p></body></html>'
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

      def users_count(users:)
        "#{users.length} users"
      end
    end.new

    users = [
      {name: 'Jane', email: 'jane@doe.org'},
      {name: 'Joe', email: 'joe@doe.org'}
    ]

    expect(vc.(users: users, context: context).to_s).to eql(
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

      expose :users

      expose :users_count do |prefix, users:|
        "#{prefix}#{users.length} users"
      end
    end.new

    users = [
      {name: 'Jane', email: 'jane@doe.org'},
      {name: 'Joe', email: 'joe@doe.org'}
    ]

    input = {users: users, context: context}

    expect(vc.(input).to_s).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><ul><li>Jane (jane@doe.org)</li><li>Joe (joe@doe.org)</li></ul><div class="count">COUNT: 2 users</div></body></html>'
    )

    expect(vc.(input).locals).to include(:users, :users_count)
    expect(vc.(input).locals).not_to include(:prefix)
  end

  it 'inherit exposures from parent class' do
    parent = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'users_with_count_inherit'
        config.default_format = :html
      end

      private_expose :prefix do
        "COUNT: "
      end

      expose :users

      expose :users_count do |prefix, users:|
        "#{prefix}#{users.length} users"
      end
    end

    child = Class.new(parent) do
      expose :child_expose do
        'Child expose'
      end
    end.new

    users = [
      {name: 'Jane', email: 'jane@doe.org'},
      {name: 'Joe', email: 'joe@doe.org'}
    ]

    input = {users: users, context: context}

    expect(child.(input).to_s).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><ul><li>Jane (jane@doe.org)</li><li>Joe (joe@doe.org)</li></ul><div class="count">COUNT: 2 users</div><div class="inherit">Child expose</div></body></html>'
    )

    expect(child.(input).locals).to include(:users, :users_count, :child_expose)
    expect(child.(input).locals).not_to include(:prefix)
  end

  it 'inherit exposures from parent class and allow to override them' do
    parent = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app'
        config.template = 'users_with_count_inherit'
        config.default_format = :html
      end

      private_expose :prefix do
        "COUNT: "
      end

      expose :users

      expose :users_count do |prefix, users:|
        "#{prefix}#{users.length} users"
      end
    end

    child = Class.new(parent) do
      expose :child_expose do
        'Child expose'
      end

      expose :users_count do |prefix, users:|
        "#{prefix}#{users.length} users overrided"
      end
    end.new

    users = [
      {name: 'Jane', email: 'jane@doe.org'},
      {name: 'Joe', email: 'joe@doe.org'}
    ]

    input = {users: users, context: context}

    expect(child.(input).to_s).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><ul><li>Jane (jane@doe.org)</li><li>Joe (joe@doe.org)</li></ul><div class="count">COUNT: 2 users overrided</div><div class="inherit">Child expose</div></body></html>'
    )

    expect(child.(input).locals).to include(:users, :users_count, :child_expose)
    expect(child.(input).locals).not_to include(:prefix)
  end

  it 'makes exposures available to layout' do
    vc = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = 'app_with_users'
        config.exposure_in_layout = true
        config.template = 'users'
        config.default_format = :html
      end

      expose :users
    end.new

    users = [
      { name: 'Jane', email: 'jane@doe.org' },
      { name: 'Joe', email: 'joe@doe.org' }
    ]

    expect(vc.(users: users, context: context).to_s).to eql(
      '<!DOCTYPE html><html><head><title>dry-view rocks!</title></head><body><p>2 users</p><div class="users"><table><tbody><tr><td>Jane</td><td>jane@doe.org</td></tr><tr><td>Joe</td><td>joe@doe.org</td></tr></tbody></table></div><img src="mindblown.jpg" /></body></html>'
    )
  end
end
