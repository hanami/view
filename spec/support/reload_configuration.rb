# frozen_string_literal: true

RSpec.shared_context "reload configuration" do
  before do
    Hanami::View.unload!
    Hanami::View.class_eval do
      configure do
        root Pathname.new(__dir__).join("fixtures", "templates")
      end
    end

    Hanami::View.load!
  end
end
