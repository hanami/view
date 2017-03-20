RSpec.describe Hanami::View::Rendering::NullLocal do
  before do
    @null = Hanami::View::Rendering::NullLocal.new(:result)
  end

  it 'does not complain for unknown sent messages' do
    actual = @null.foo

    pending('Meta-programming weirdness is going on here, better to fix the code than the test...')

    expect(actual).to be_instance_of(Hanami::View::Rendering::NullLocal)
    expect(actual.inspect).to match ':result.foo'
  end

  it 'returns empty string for to_str' do
    expect(@null.to_str).to eq('')
  end

  it 'returns empty string for to_s' do
    expect(@null.to_s).to eq('')
  end

  it 'returns false to all?' do
    expect(@null.all?).to eq(false)
  end

  it 'returns false to any?' do
    expect(@null.any?).to eq(false)
  end

  it 'returns true to empty?' do
    expect(@null.empty?).to eq(true)
  end

  it 'returns true to nil?' do
    expect(@null.nil?).to eq(true)
  end

  it 'returns false to any method ending with question mark' do
    expect(@null.downloadable?).to eq(false)
  end

  it 'always returns true for respond_to? check' do
    expect(@null).to respond_to(:bar)
  end

  it 'contains the name of the local in #inspect' do
    expect(@null.inspect).to match ':result'
  end
end
