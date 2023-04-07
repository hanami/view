# frozen_string_literal: true

RSpec.describe Hanami::Helpers::NumberFormattingHelper do
  let(:view) { NumbersView.new }

  it "returns string representation of one" do
    expect(view.single_digit).to eq("1")
  end

  it "returns string representation of one thousand" do
    expect(view.thousand_digits).to eq("1,000")
  end

  it "returns string representation of one million" do
    expect(view.million_digits).to eq("1,000,000")
  end

  it "returns string representation of point one" do
    expect(view.zero_point_one).to eq("0.10")
  end

  it "returns string representation of 5 thousand and 2 point 007" do
    expect(view.mixed_digits).to eq("5,002.007")
  end

  it "formats precision to 2dp by default" do
    expect(view.precision_default_format).to eq("3.14")
  end

  it "returns string formatted to 4dp" do
    expect(view.precision_format).to eq("3.1416")
  end

  it "returns string padded with zeros" do
    expect(view.precision_higher_than_numbers_precision).to eq("3.1400")
  end

  it "returns string with no decimal part" do
    expect(view.zero_precision).to eq("3")
  end

  it 'returns string with "." delimiter and "," separator' do
    expect(view.euro_format).to eq("1.234,12")
  end

  it "raises TypeError when nil is passed" do
    expect { view.pass_nil }.to raise_error(Hanami::Helpers::CoercionError)
  end

  it "raises a TypeError when a class name is passed" do
    expect { view.pass_class_name }.to raise_error(Hanami::Helpers::CoercionError)
  end

  it "raises a TypeError when a string cannot be coerced into a float" do
    expect { view.pass_string }.to raise_error(Hanami::Helpers::CoercionError)
  end

  it "returns string when passed a string that represent an integer" do
    expect(view.pass_non_numeric_integer).to eq("1")
  end

  it "returns string when passed a string that represent a float" do
    expect(view.pass_non_numeric_float).to eq("1.00")
  end

  it "returns string when passed BigDecimal" do
    expect(view.big_decimal).to eq("0.0001")
  end

  it "returns string when passed Complex" do
    expect(view.complex).to eq("1.00")
  end

  it "returns string when passed a Rational" do
    expect(view.rational).to eq("1.00")
  end

  it "returns infinity representation" do
    expect(view.infinity).to eq("Inf")
  end

  it "returns NaN representation" do
    expect(view.nan).to eq("NaN")
  end
end
