RSpec.describe Dry::View::Decorator do
  subject(:decorator) { described_class.new }

  describe '#call' do
    let(:value) { double('value') }
    let(:renderer) { double('renderer') }
    let(:context) { double('context') }
    let(:options) { {} }

    describe 'returning a part value' do
      subject(:part) { decorator.('user', value, renderer: renderer, context: context, **options) }

      context 'no options provided' do
        it 'returns a Part' do
          expect(part).to be_a Dry::View::Part
        end

        it 'wraps the value' do
          expect(part._value).to eq value
        end
      end

      context 'part class provided via `:as` option' do
        let(:options) { {as: Test::CustomPart} }

        before do
          module Test
            CustomPart = Class.new(Dry::View::Part)
          end
        end

        it 'returns an instance of the provided class' do
          expect(part).to be_a Test::CustomPart
        end

        it 'wraps the value' do
          expect(part._value).to eq value
        end
      end

      context 'value is an array' do
        let(:child_a) { double('child a') }
        let(:child_b) { double('child a') }
        let(:value) { [child_a, child_b] }

        it 'returns a part wrapping the array' do
          expect(part).to be_a Dry::View::Part
          expect(part._value).to be_an Array
        end

        it 'wraps the elements within the array' do
          expect(part[0]).to be_a Dry::View::Part
          expect(part[0]._value).to eq child_a

          expect(part[1]).to be_a Dry::View::Part
          expect(part[1]._value).to eq child_b
        end
      end
    end
  end
end
