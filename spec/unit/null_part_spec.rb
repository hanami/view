require 'dry/view/null_part'

RSpec.describe Dry::View::NullPart do
  subject(:part) do
    Dry::View::NullPart.new(renderer, {user: nil})
  end

  let(:renderer) { double(:renderer) }

  describe '#[]' do
    it 'returns nil for any data value names' do
      expect(part[:email]).to eql(nil)
    end
  end

  describe "#with" do
    it "builds a new instance with the extra data" do
      expect(part.with(foo: "bar")).to eq Dry::View::NullPart.new(renderer, {user: nil, foo: "bar"})
    end

    it "returns self when no data passed" do
      expect(part.with({})).to eql part
    end
  end

  describe '#method_missing' do
    context 'template matches' do
      it 'renders template with the _missing suffix' do
        expect(renderer).to receive(:lookup).with('_row_missing').and_return('_row_missing.slim')
        expect(renderer).to receive(:render).with('_row_missing.slim', part)

        part.row
      end

      it 'renders template with extra data when a hash is passed' do
        expect(renderer).to receive(:lookup).with('_fields_missing').and_return('_fields_missing.html.slim')
        expect(renderer).to receive(:render).with('_fields_missing.html.slim', part.with(foo: "bar"))

        part.fields(foo: "bar")
      end

      it "renders template with extra data (keyed by the template's name) when any other object is passed" do
        my_thing = Object.new

        expect(renderer).to receive(:lookup).with('_fields_missing').and_return('_fields_missing.html.slim')
        expect(renderer).to receive(:render).with('_fields_missing.html.slim', part.with(fields: my_thing))

        part.fields(my_thing)
      end

      it 'renders a _missing template within another when block is passed' do
        block = proc { part.fields }

        expect(renderer).to receive(:lookup).with('_form_missing').and_return('form_missing.slim')
        expect(renderer).to receive(:lookup).with('_fields_missing').and_return('fields_missing.slim')

        expect(renderer).to receive(:render).with('form_missing.slim', part, &block)
        expect(renderer).to receive(:render).with('fields_missing.slim', part)

        part.form(&block)
      end
    end
  end
end
