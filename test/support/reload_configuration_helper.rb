class Minitest::Spec
  def self.reload_configuration!
    before do
      Hanami::View.unload!
      Hanami::View.class_eval do
        configure do
          root Pathname.new(__dir__).join('..', 'fixtures', 'templates')
        end
      end

      Hanami::View.load!
    end
  end
end
