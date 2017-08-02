RSpec.describe Hanami::Presenter do
  subject do
    MapPresenter.new(map)
  end

  let(:map) { Map.new(['Rome']) }

  it 'forwards methods to the wrapped object' do
    expect(subject.locations).to eq map.locations
  end

  it 'uses concrete methods' do
    expect(subject.count).to eq map.locations.count
  end

  it 'uses super to access object implementation' do
    expect(subject.location_names).to eq map.locations.map {|l| l.upcase }.join(', ')
  end

  it 'has a direct access to the object' do
    expect(subject.inspect).to include '#<Map:'
  end

  it 'responds to whatever the object responds to' do
    expect(subject).to respond_to :locations
    expect(subject).to_not respond_to :unknown_method
  end

  describe 'escape' do
    let(:map) { Map.new(["<script>alert('rome')</script>"]) }

    it 'auto escapes contents' do
      expect(subject.location_names).to eq %(&LT;SCRIPT&GT;ALERT(&APOS;ROME&APOS;)&LT;&#X2F;SCRIPT&GT;)
    end

    it 'auto escapes inherited methods' do
      expect(subject.names).to eq %(&lt;script&gt;alert(&apos;rome&apos;)&lt;&#x2F;script&gt;)
    end

    it 'auto escapes concrete methods' do
      expect(subject.escaped_location_names).to eq %(&lt;script&gt;alert(&apos;rome&apos;)&lt;&#x2F;script&gt;)
    end

    it 'allows raw contents' do
      expect(subject.raw_location_names).to eq map.location_names
    end
  end

  it "raises error when the requested method can't be satisfied" do
    expect do
      subject.unknown_method
    end.to raise_error NoMethodError
  end
end
