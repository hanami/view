module Hanami
  module Component
    def self.included(klass)
      klass.define_method(:application) { Hanami.application }
      klass.define_method(:provider) do
        raise "Hanami.application must be inited before detecting providers" unless application.inited?

        # [Admin, Main, MyApp] or [MyApp::Admin, MyApp::Main, MyApp]
        providers = application.slices.values + [application]

        component_name = self.class.name

        return unless component_name

        providers.detect { |provider| component_name.include?(provider.namespace.to_s) }
      end
    end
  end
end
