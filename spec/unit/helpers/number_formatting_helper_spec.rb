require "bigdecimal"

RSpec.describe Hanami::View::Helpers::NumberFormattingHelper, "#format_number" do
  subject(:obj) {
    Class.new {
      include Hanami::View::Helpers::NumberFormattingHelper
    }.new
  }

  def h(&block)
    obj.instance_eval(&block)
  end

  it "returns string representation of one" do
    expect(h { format_number(1) }).to eq("1")
  end

  it "returns string representation of one thousand" do
    expect(h { format_number(1_000) }).to eq("1,000")
  end

  it "returns string representation of one million" do
    expect(h { format_number(1_000_000) }).to eq("1,000,000")
  end

  it "returns string representation of point one" do
    expect(h { format_number(0.1) }).to eq("0.10")
  end

  it "returns string representation of 5 thousand and 2 point 007" do
    expect(h { format_number(5002.007, precision: 3) }).to eq("5,002.007")
  end

  it "formats precision to 2dp by default" do
    expect(h { format_number(Math::PI) }).to eq("3.14")
  end

  it "returns string formatted to 4dp" do
    expect(h { format_number(Math::PI, precision: 4) }).to eq("3.1416")
  end

  it "returns string padded with zeros" do
    expect(h { format_number(3.14, precision: 4) }).to eq("3.1400")
  end

  it "returns string with no decimal part" do
    expect(h { format_number(3.14, precision: 0) }).to eq("3")
  end

  it 'returns string with "." delimiter and "," separator' do
    expect(h { format_number(1234.12, delimiter: ".", separator: ",") }).to eq("1.234,12")
  end

  it "raises ArgumentError when nil is passed" do
    expect { h { format_number(nil) } }.to raise_error(ArgumentError)
  end

  it "raises a TypeError when a class name is passed" do
    expect { h { format_number(Object) } }.to raise_error(ArgumentError)
  end

  it "raises a TypeError when a string cannot be coerced into a float" do
    expect { h { format_number("string") } }.to raise_error(ArgumentError)
  end

  it "returns string when passed a string that represent an integer" do
    expect(h { format_number("1") }).to eq("1")
  end

  it "returns string when passed a string that represent a float" do
    expect(h { format_number("1.0") }).to eq("1.00")
  end

  it "returns string when passed BigDecimal" do
    expect(h { format_number(BigDecimal("0.0001"), precision: 4) }).to eq("0.0001")
  end

  it "returns string when passed Complex" do
    expect(h { format_number(Complex(1)) }).to eq("1.00")
  end

  it "returns string when passed a Rational" do
    expect(h { format_number(Rational(1)) }).to eq("1.00")
  end

  it "returns infinity representation" do
    expect(h { format_number(Float::INFINITY) }).to eq("Inf")
  end

  it "returns NaN representation" do
    expect(h { format_number(0.0 / 0) }).to eq("NaN")
  end
end
