# frozen_string_literal: true

require 'dry/view'
require 'dry/view/context'

RSpec.describe 'View / errors' do
  specify 'Raising an error when paths are not configured' do
    view = Class.new(Dry::View) do
      config.template = 'hello'
    end.new

    expect { view.() }.to raise_error(Dry::View::UndefinedConfigError, 'no +paths+ configured')
  end

  specify 'Raising an error when template is not configured' do
    view = Class.new(Dry::View) do
      config.paths = FIXTURES_PATH.join('integration/errors')
    end.new

    expect { view.() }.to raise_error(Dry::View::UndefinedConfigError, 'no +template+ configured')
  end
end
