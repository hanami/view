RSpec.describe Hanami::View::Template do
  describe '#initialize' do
    it 'accepts one argument' do
      template = Hanami::View::Template.new("#{TEMPLATE_ROOT_DIRECTORY}/hello_world.html.erb")
      expect(template.instance_variable_get(:@_template).__send__(:default_encoding)).to eq Encoding::UTF_8
    end

    it 'allows to specify encoding (as string)' do
      template = Hanami::View::Template.new("#{TEMPLATE_ROOT_DIRECTORY}/hello_world.html.erb", 'ISO-8859-1')
      expect(template.instance_variable_get(:@_template).__send__(:default_encoding)).to eq 'ISO-8859-1'
    end

    it 'allows to specify encoding (as constant)' do
      template = Hanami::View::Template.new("#{TEMPLATE_ROOT_DIRECTORY}/hello_world.html.erb", Encoding::ISO_8859_1)
      expect(template.instance_variable_get(:@_template).__send__(:default_encoding)).to eq Encoding::ISO_8859_1
    end
  end
end
