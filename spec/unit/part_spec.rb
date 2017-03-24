RSpec.describe Dry::View::Part do
  subject(:part) { described_class.new(value, renderer: renderer, context: context, locals: locals) }

  let(:locals) { {} }
  let(:value) { double('value') }
  let(:context) { double('context') }
  let(:renderer) { double('renderer') }

  describe '#render' do
    before do
      allow(renderer).to receive(:lookup).with('_info').and_return '_info.html.erb'
      allow(renderer).to receive(:render)
    end

    it 'renders a partial using the supplied renderer' do
      part.render(:info)
      expect(renderer).to have_received(:render).with('_info.html.erb', any_args)
    end

    describe 'render scope' do
      context 'scope argument not supplied' do
        it 'is the part itself' do
          part.render(:info)
          expect(renderer).to have_received(:render).with('_info.html.erb', part)
        end

        it 'replaces locals with those provided' do
          part.render(:info, foo: 'bar')
          expect(renderer).to have_received(:render).with('_info.html.erb', itself_with(locals: {foo: 'bar'}))
        end
      end

      context 'plain value supplied as scope argument' do
        it 'wraps the value in a new part, keeping existing renderer, context, and locals' do
          part.render(:info, 'hello')
          expect(renderer).to have_received(:render).with('_info.html.erb', itself_with('hello'))
        end

        it 'replaces locals with those provided' do
          part.render(:info, 'hello', foo: 'bar')
          expect(renderer).to have_received(:render).with('_info.html.erb', itself_with('hello', locals: {foo: 'bar'}))
        end
      end

      context 'part object supplied as scope argument' do
        it 'is the supplied part' do
          another_part = itself_with('hello')
          part.render(:info, another_part)
          expect(renderer).to have_received(:render).with('_info.html.erb', another_part)
        end

        it 'replaces locals with those provided' do
          another_part = itself_with('hello')
          part.render(:info, another_part, foo: 'bar')
          expect(renderer).to have_received(:render).with('_info.html.erb', itself_with('hello', locals: {foo: 'bar'}))
        end
      end
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

  describe '#method_missing' do
    describe 'matching locals' do
      let(:locals) { {greeting: 'hello from locals'} }
      let(:object) { double(greeting: 'hello from object') }
      let(:context) { double(greeting: 'hello from context') }

      it 'returns a matching local, in favour of matches on the object and context' do
        expect(part.greeting).to eq 'hello from locals'
      end
    end

    describe 'matching the value' do
      let(:context) { double(greeting: 'hello from context') }

      describe 'methods' do
        let(:value) { double(greeting: 'hello from value') }

        it 'calls a matching method on the value, in favour of a matching method on the context' do
          expect(part.greeting).to eq 'hello from value'
        end

        it 'forwards all arguments to the method' do
          allow(value).to receive(:farewell)

          blk = -> { }
          part.farewell "args here", &blk

          expect(value).to have_received(:farewell).with("args here", &blk)
        end
      end

      describe 'hash keys' do
        let(:value) { {greeting: 'hello from value hash'} }

        it 'returns a matching value from the value, in favour of a matching method on the context' do
          expect(part.greeting).to eq 'hello from value hash'
        end
      end
    end

    describe 'matching the context' do
      let(:context) { double(greeting: 'hello from context') }

      it 'calls the matching method on the context' do
        expect(part.greeting).to eq 'hello from context'
      end

      it 'forwards all arguments to the method' do
        allow(context).to receive(:farewell)

        blk = -> { }
        part.farewell "args here", &blk

        expect(context).to have_received(:farewell).with("args here", &blk)
      end
    end

    describe 'no matches' do
      it 'raises an error' do
        expect { part.greeting }.to raise_error(NoMethodError)
      end
    end
  end

  def itself_with(new_object = part._object, **overrides)
    described_class.new(
      new_object,
      {
        renderer: part._renderer,
        context: part._context,
        locals: part._locals
      }.merge(overrides)
    )
  end
end
