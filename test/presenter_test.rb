require 'test_helper'

describe Lotus::Presenter do
  subject do
    MapPresenter.new(map)
  end

  let(:map) { Map.new(['Rome']) }

  it 'forwards methods to the wrapped object' do
    subject.locations.must_equal map.locations
  end

  it 'uses concrete methods' do
    subject.count.must_equal map.locations.count
  end

  it 'uses super to access object implementation' do
    subject.location_names.must_equal map.locations.map {|l| l.upcase }.join(', ')
  end

  it 'has a direct access to the object' do
    subject.inspect_object.must_match '#<Map'
  end

  it 'responds to whatever the object responds to' do
    subject.must_respond_to :locations
    subject.wont_respond_to :unknown_method
  end

  describe 'escape' do
    let(:map) { Map.new(["<script>alert('rome')</script>"]) }

    it 'auto escapes contents' do
      subject.location_names.must_equal %(&LT;SCRIPT&GT;ALERT(&APOS;ROME&APOS;)&LT;&#X2F;SCRIPT&GT;)
    end

    it 'auto escapes inherited methods' do
      subject.names.must_equal %(&lt;script&gt;alert(&apos;rome&apos;)&lt;&#x2F;script&gt;)
    end

    it 'auto escapes concrete methods' do
      subject.escaped_location_names.must_equal %(&lt;script&gt;alert(&apos;rome&apos;)&lt;&#x2F;script&gt;)
    end

    it 'allows raw contents' do
      subject.raw_location_names.must_equal map.location_names
    end
  end

  it "raises error when the requested method can't be satisfied" do
    -> {
      subject.unknown_method
    }.must_raise NoMethodError
  end
end
