# frozen_string_literal: true

require "hanami"
require "hanami/view/context"

RSpec.describe "Application context / Routes", :application_integration do
  it "accesses application routes" do
    with_tmp_directory(Dir.mktmpdir) do
      write "config/application.rb", <<~RUBY
        require "hanami"

        module TestApp
          class Application < Hanami::Application
          end
        end
      RUBY

      write "config/routes.rb", <<~RUBY
        module TestApp
          class Routes < Hanami::Application::Routes
            define do
              slice :main, at: "/" do
                root to: "test_action"
              end
            end
          end
        end
      RUBY

      write "lib/test_app/view/context.rb", <<~RUBY
        module TestApp
          module View
            class Context < Hanami::View::Context
            end
          end
        end
      RUBY

      require "hanami/init"

      context = TestApp::View::Context.new
      expect(context.routes.path(:root)).to eq "/"
    end
  end

  it "can inject routes" do
    module TestApp
      class Application < Hanami::Application
      end
    end
    Hanami.init
    module TestApp
      module View
        class Context < Hanami::View::Context
        end
      end
    end
    routes = double(:routes)

    context = TestApp::View::Context.new(routes: routes)

    expect(context.routes).to be(routes)
  end
end
