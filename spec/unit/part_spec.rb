require 'dry/view/scope_builder'

RSpec::Matchers.define :scope do |locals|
  match do |actual|
    locals == actual._locals
  end
end

RSpec.describe Dry::View::Part do
  let(:name) { :user }
  let(:value) { double(:value) }
  let(:rendering) {
    Dry::View::Rendering.new(
      renderer: renderer,
      inflector: Dry::Inflector.new,
      context: Dry::View::Context.new,
      scope_builder: Dry::View::ScopeBuilder.new,
      part_builder: Dry::View::ScopeBuilder.new,
    )
  }
  let(:renderer) { spy(:renderer) }

  context 'with a renderer' do
    subject(:part) {
      described_class.new(
        name: name,
        value: value,
        rendering: rendering,
      )
    }

    describe '#render' do
      it 'renders a partial with the part available in its scope' do
        part.render(:info)
        expect(renderer).to have_received(:partial).with(:info, scope(user: part))
      end

      it 'allows the part to be made available on a different name' do
        part.render(:info, as: :admin)
        expect(renderer).to have_received(:partial).with(:info, scope(admin: part))
      end

      it 'includes extra locals in the scope' do
        part.render(:info, extra_local: "hello")
        expect(renderer).to have_received(:partial).with(:info, scope(user: part, extra_local: "hello"))
      end
    end

    describe '#to_s' do
      before do
        allow(value).to receive(:to_s).and_return 'to_s on the value'
      end

      it 'delegates to the wrapped value' do
        expect(part.to_s).to eq 'to_s on the value'
      end
    end

    describe '#new' do
      it 'preserves rendering' do
        new_part = part.new(value: 'new value')
        expect(new_part._rendering).to eql part._rendering
      end
    end

    describe "#inspect" do
      it "includes the clsas name, name, and value only" do
        expect(part.inspect).to eq "#<Dry::View::Part name=:user value=#<Double :value>>"
      end
    end

    describe '#method_missing' do
      let(:value) { double(greeting: 'hello from value') }

      it 'calls a matching method on the value' do
        expect(part.greeting).to eq 'hello from value'
      end

      it 'forwards all arguments to the method' do
        blk = -> { }
        part.greeting 'args', &blk

        expect(value).to have_received(:greeting).with('args', &blk)
      end

      it 'raises an error if no metho matches' do
        expect { part.farewell }.to raise_error(NoMethodError)
      end
    end

    describe '#respond_to' do
      let(:value) { double(greeting: 'hello from value') }

      it 'handles convenience methods' do
        expect(part).to respond_to(:context)
        expect(part).to respond_to(:render)
        expect(part).to respond_to(:value)
      end

      it 'handles value methods' do
        expect(part).to respond_to(:greeting)
      end
    end
  end
end
