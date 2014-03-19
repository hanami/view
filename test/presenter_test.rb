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

  it "raises error when the requested method can't be satisfied" do
    -> {
      subject.unknown_method
    }.must_raise NoMethodError
  end
end
