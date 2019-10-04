---
title: Context
layout: gem-single
name: dry-view
---

Use a context object to provide shared facilities to every template, partial, scope, and part in a given view rendering.

A context object is helpful in holding any behaviour or data you don't want to pass around explicitly. For example:

- Data speicifc to the current HTTP request, like the request path and CSRF tags
- A "current user" or similar session-based object needed across multiple disparate places
- Application static assets helpers
- `content_for`-style helpers

## Defining a context

Context classes must inherit from `Dry::View::Context`

```ruby
class MyContext < Dry::View::Context
end
```

## Injecting dependencies

`Dry::View::Context` is designed to allow dependencies to be injected into your subclasses. To do this, accept your dependencies as keyword arguments to `#initialize`, and pass every other keyword argument through to `super`:

```ruby
class MyContext < Dry::View::Context
  attr_reader :assets

  def initialize(assets:, **args)
    @assets = assets
    super(**args)
  end

  def asset_path(asset_name)
    assets[asset_name]
  end
end
```

If your app uses [dry-system](/gems/dry-system) or [dry-auto_inject](/gems/dry-auto_inject), this is even less work. dry-auto_inject works out of the box with `Dry::View::Context`’s initializer:

```ruby
# Require the auto-injector module for your app's container
require "my_app/import"

class MyContext < Dry::View::Context
  include MyApp::Import["assets"]

  def asset_path(asset_name)
    assets[asset_name]
  end
end
```

## Providing the context

The default context can be `configured` for a view:

```ruby
class MyView < Dry::Vew
  config.default_context = MyContext.new
end
```

Or provided at render-time, when calling a view:

```ruby
my_view.call(context: my_context)
```

This context object will override whatever has been previously configured.

When providing a context at render time, you may wish to provide a version of your context object with e.g. data specific to the current HTTP request, which is not available when configuring the view with a context.

## Decorating context attributes

Your context may have attribute that you want decorated as [parts](/gems/dry-view/parts/). Declare these using `decorate` in your context class:

```ruby
class MyContext < Dry::View::Context
  decorate :navigation_items

  attr_reader :navigation_items

  def initialize(navigation_items:, **args)
    @navigation_items = navigation_items
    super(**args)
  end
end
```

You can pass the same options to `decorate` as you do to [exposures](/gems/dry-view/exposures/), for example:

```ruby
class MyContext < Dry::View::Context
  decorate :navigation_items, as: :menu_items

  # ...
end
```
