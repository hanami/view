module Hanami
  # Adds knowledge about an active Hanami app
  #
  # Some of this knowledge is fetched by just forwarding to {Hanami} itself, like
  # {#application}. Other, is dependant on the hierarchy of the extending class
  # or module within the Hanami application, like {#provider}.
  module Component
    def application
      raise "A Hanami application must exist" unless Hanami.application?

      Hanami.application
    end

    def provider
      raise "Hanami.application must be inited before detecting providers" unless application.inited?

      # [Admin, Main, MyApp] or [MyApp::Admin, MyApp::Main, MyApp]
      providers = application.slices.values + [application]

      return unless name

      providers.detect { |provider| name.include?(provider.namespace.to_s) }
    end
  end
end
