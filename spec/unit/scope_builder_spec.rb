# frozen_string_literal: true

RSpec.describe Hanami::View::ScopeBuilder, "#call" do
  subject(:scope_builder) { rendering.scope_builder }

  let(:rendering) { view.rendering(format: :html) }
  let(:view) {
    scope_namespace = namespace
    Class.new(Hanami::View) {
      config.paths = FIXTURES_PATH
      config.template = "_"
      config.scope_namespace = scope_namespace
    }.new
  }
  let(:namespace) { nil }

  describe "caching" do
    let(:scope_one) { Class.new(Hanami::View::Scope) }
    let(:scope_two) { Class.new(Hanami::View::Scope) }

    before do
      Hanami::View::Cache.clear

      stub_const "ScopeOne", scope_one
      stub_const "ScopeTwo", scope_two
    end

    it "caches each resolved scope" do
      scope_builder.call("scope_one", locals: {}, rendering: rendering)
      scope_builder.call("scope_two", locals: {}, rendering: rendering)

      expect(Hanami::View::Cache.cache.values).to eq [ScopeOne, ScopeTwo]
    end
  end
end
