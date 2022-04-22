RSpec.describe "Tempalte rendering / locals" do
  let(:base_view) {
    Class.new(Hanami::View) do
      config.paths = FIXTURES_PATH.join("integration/template_rendering/locals")
    end
  }

  specify "Accessing all `locals` inside template" do
    view = Class.new(base_view) do
      config.template = "locals_in_template"

      expose :text, decorate: false
    end.new

    expect(view.(text: "Hello").to_s).to eq %{Locals: {:text=>"Hello"}}
  end
end
