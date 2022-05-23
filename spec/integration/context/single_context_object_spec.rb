# frozen_string_literal: true

RSpec.describe "Context / Single context object" do
  let(:view) {
    Class.new(Hanami::View) {
      config.paths = FIXTURES_PATH.join("integration/context/single_context_object")
      config.template = "single_context_object"
    }.new
  }

  let(:context) {
    Class.new(Hanami::View::Context) {
      attr_reader :context_id

      def initialize(*)
        super
        @context_id = object_id
      end
    }.new
  }

  it "uses the same context object across differens renderings (main template plus partials)" do
    context_id = context.object_id

    expect(view.(context: context).to_s).to eq (<<~TEXT).strip
      Context object ID: #{context_id}<br />Context object ID from partial: #{context_id}
    TEXT
  end
end
