class Minitest::Spec
  def self.reload_configuration!
    before do
      Lotus::View.unload!
      Lotus::View.class_eval do
        configure do
          root Pathname.new __dir__ + '/fixtures/templates'
        end
      end

      Lotus::View.load!
    end
  end
end
