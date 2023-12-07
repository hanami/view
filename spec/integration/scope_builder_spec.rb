# frozen_string_literal: true

RSpec.describe "scope builder" do
  describe "default scope builder" do
    it "defaults to creating instances of Hanami::View::Scope" do
      view = Class.new(Hanami::View) do
        config.paths = SPEC_ROOT.join("__ignore__")
        config.template = "__ignore__"
      end.new

      scope = view.rendering.scope({})

      expect(scope).to be_an_instance_of Hanami::View::Scope
    end

    it "create instances of a configured scope_class" do
      scope_class = Class.new(Hanami::View::Scope)

      view = Class.new(Hanami::View) do
        config.paths = SPEC_ROOT.join("__ignore__")
        config.template = "__ignore__"

        config.scope_class = scope_class
      end.new

      scope = view.rendering.scope({})

      expect(scope).to be_an_instance_of scope_class
    end

    context 'when multiple scopes are rendered in the same view' do

      let(:builder) { described_class.new }

      it 'allows to build scopes with different classes' do
        FirstScopeClass =  Class.new(Hanami::View::Scope)
        SecondScopeClass =  Class.new(Hanami::View::Scope)

        view = Class.new(Hanami::View) do
          config.paths = SPEC_ROOT.join("__ignore__")
          config.template = "__ignore__"

          config.scope_class = FirstScopeClass
        end.new

        scope = view.rendering.scope({})
        expect(scope).to be_an_instance_of FirstScopeClass

        scope = view.rendering.scope('SecondScopeClass', {})
        expect(scope).to be_an_instance_of SecondScopeClass

        scope = view.rendering.scope('FirstScopeClass', {})
        expect(scope).to be_an_instance_of FirstScopeClass
      end
    end
  end
end
