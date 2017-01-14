require 'dry/view/part'

RSpec.describe Dry::View::Part do
  subject(:part) do
    Dry::View::Part.new(renderer)
  end

  let(:renderer) { double(:renderer) }

  describe '#render' do
    it 'renders given template' do
      expect(renderer).to receive(:render).with('row.slim', part)

      part.render('row.slim')
    end
  end

  describe '#template?' do
    it 'asks renderer if there is a valid template for a given identifier' do
      expect(renderer).to receive(:lookup).with('_row').and_return('row.slim')

      expect(part.template?('row')).to eql('row.slim')
    end
  end

  describe '#method_missing' do
    context 'template matches' do
      it 'renders template' do
        expect(renderer).to receive(:lookup).with('_row').and_return('_row.slim')
        expect(renderer).to receive(:render).with('_row.slim', part)

        part.row

      end

      it 'renders template with extra data when a hash is passed' do
        expect(renderer).to receive(:lookup).with('_fields').and_return('_fields.html.slim')
        expect(renderer).to receive(:render).with('_fields.html.slim', part_including(foo: "bar"))

        part.fields(foo: "bar")
      end

      it 'renders template within another when block is passed' do
        block = proc { part.fields }

        expect(renderer).to receive(:lookup).with('_form').and_return('form.slim')
        expect(renderer).to receive(:lookup).with('_fields').and_return('fields.slim')

        expect(renderer).to receive(:render).with('form.slim', part, &block)
        expect(renderer).to receive(:render).with('fields.slim', part)

        part.form(&block)
      end
    end
  end
end
