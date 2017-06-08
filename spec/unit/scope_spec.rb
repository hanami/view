RSpec.describe Dry::View::Scope do
  subject(:scope) { described_class.new(renderer: renderer, context: context, locals: locals) }

  let(:locals) { {} }
  let(:context) { double('context') }
  let(:renderer) { double('renderer') }

  describe '#render' do
    context 'partial found' do
      before do
        allow(renderer).to receive(:lookup).with('_info').and_return '_info.html.erb'
        allow(renderer).to receive(:render)
      end

      it 'renders a partial with itself as the scope' do
        scope.render(:info)
        expect(renderer).to have_received(:render).with('_info.html.erb', scope)
      end

      it 'renders a partial with provided locals' do
        scope_with_locals = described_class.new(renderer: renderer, context: context, locals: {foo: 'bar'})

        scope.render(:info, foo: 'bar')
        expect(renderer).to have_received(:render).with('_info.html.erb', scope_with_locals)
      end
    end

    context 'partial not found' do
      before do
        allow(renderer).to receive(:lookup).with('_info').and_return false
        allow(renderer).to receive(:render)
      end

      it 'raises error when partial was not found' do
        expect {
          scope.render(:info)
        }.to raise_error(Dry::View::Scope::PartialNotFoundError, /info/)
      end
    end
  end

  describe '#method_missing' do
    context 'matching locals' do
      let(:locals) { {greeting: 'hello from locals'} }
      let(:context) { double('context', greeting: 'hello from context') }

      it 'returns a matching value from the locals, in favour of a matching method on the context' do
        expect(scope.greeting).to eq 'hello from locals'
      end
    end

    context 'matching context' do
      let(:context) { double('context', greeting: 'hello from context') }

      it 'calls the matching method on the context' do
        expect(scope.greeting).to eq 'hello from context'
      end

      it 'forwards all arguments to the method' do
        blk = -> { }
        scope.greeting 'args', &blk

        expect(context).to have_received(:greeting).with('args', &blk)
      end
    end

    describe 'no matches' do
      it 'raises an error' do
        expect { scope.greeting }.to raise_error(NoMethodError)
      end
    end
  end
end
