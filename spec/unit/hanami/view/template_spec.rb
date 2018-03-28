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

    describe ':disable_escape option' do
      it 'avoids the :disable_escape option with haml templates' do
        template = Hanami::View::Template.new("#{TEMPLATE_ROOT_DIRECTORY}/contacts.html.haml")
        expect(template.instance_variable_get(:@_template).__send__(:options)[:disable_escape]).to eq(nil)
      end

      it 'sets :disable_escape to true with non-haml templates' do
        template = Hanami::View::Template.new("#{TEMPLATE_ROOT_DIRECTORY}/hello_world.html.erb",)
        expect(template.instance_variable_get(:@_template).__send__(:options)[:disable_escape]).to eq(true)
      end
    end
  end
end
