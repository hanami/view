module Hanami
  module Component
    def application
      Hanami.application
    end

    def provider
      raise "Hanami.application must be inited before detecting providers" unless application.inited?

      # [Admin, Main, MyApp] or [MyApp::Admin, MyApp::Main, MyApp]
      providers = application.slices.values + [application]

      component_name = name

      return unless component_name

      providers.detect { |provider| component_name.include?(provider.namespace.to_s) }
    end
  end
end
