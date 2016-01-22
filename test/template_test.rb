require 'test_helper'

describe Hanami::View::Template do
  describe '#initialize' do
    it 'accepts one argument' do
      template = Hanami::View::Template.new(__dir__ + '/fixtures/templates/hello_world.html.erb')
      template.instance_variable_get(:@_template).__send__(:default_encoding).must_equal Encoding::UTF_8
    end

    it 'allows to specify encoding (as string)' do
      template = Hanami::View::Template.new(__dir__ + '/fixtures/templates/hello_world.html.erb', 'ISO-8859-1')
      template.instance_variable_get(:@_template).__send__(:default_encoding).must_equal 'ISO-8859-1'
    end

    it 'allows to specify encoding (as constant)' do
      template = Hanami::View::Template.new(__dir__ + '/fixtures/templates/hello_world.html.erb', Encoding::ISO_8859_1)
      template.instance_variable_get(:@_template).__send__(:default_encoding).must_equal Encoding::ISO_8859_1
    end
  end
end
