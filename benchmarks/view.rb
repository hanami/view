require 'pathname'
require 'benchmark/ips'
require 'dry/view/renderer'
require 'action_view'

class ActionRender
  include ActionView::Helpers

  def button
    link_to('User', '/users/1')
  end
end

action_renderer = ActionRender.new
dry_view_renderer = Dry::View::Renderer.new(Pathname(__FILE__).dirname.join('templates'), format: :html)

template = Pathname(__FILE__).dirname.join('templates').join('button.html.erb')
SCOPE = {}

Benchmark.ips do |x|
  x.report('actionview') { action_renderer.button }
  x.report('dry-view') { dry_view_renderer.render(template, SCOPE) }
  x.compare!
end
