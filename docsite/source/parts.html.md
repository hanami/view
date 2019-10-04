---
title: Parts
layout: gem-single
name: dry-view
---

All values [exposed](/gems/dry-view/exposures/) by your view are decorated and passed to your templates as _parts_, which allow encapsulation of view-specific behavior alongside your application's domain objects.

Unlike many third-party approaches to view object decoration, dry-view's parts are fully integrated and have access to the full rendering environment, which means that anything you can do from a template, you can also do from a part. This includes accessing the context object as well as rendering partials and building scopes.

This means that much more view logic can move out of template and into parts, which makes the templates simpler and more declarative, and puts the view logic into a place where it can be reused and refactored using typical object oriented approaches, as well as tested in isolation.

## Defining a part class

To provide custom part behavior, define your own part classes in a common namespace (e.g. `Parts`) and [configure that](/gems/dry-view/configuration/) as your view's `part_namespace` Each part class must inherit from `Dry::View::Part`.

```ruby
module Parts
  class User < Dry::View::Part
  end
end
```

## Part class resolution

Part classes are looked up based on each exposure's name.

So for an exposure named `:article`, the `Parts::Article` class will be looked up and used to decorate the article value.

For an exposure returning an array, the exposure's name will be singularized and each element in the array will be decorated with a matching part. Then the array _itself_ will be decorated by a matching part.

So for an exposure named `:articles`, the `Parts::Article` class will be looked up for decorating each element, and the `Parts::Articles` class will be looked up for decorating the entire array.

If a matching part class cannot be found, the standard `Dry::View::Part` class will be used.

## Accessing the decorated value

When using a part within a template, or when defining your own part methods, you can call the decorated value's methods and the part object will pass them through (via `#method_missing`).

For example, from a template:

```erb
<!-- All the methods on the user value are still available -->
<p><%= user.name %></p>
```

Or when defining a custom part class:

```ruby
class User < Dry::View::Part
  def display_name
    # `name` and `email` are methods on the decorated user value
    "#{name} <#{email}>"
  end
end
```

In case of naming collisions or when overriding a method, you can access the value directly via `#_value` (or `#value` as a convenience, as long the decorated value itself doesn't respond to `#value`):

```ruby
class User < Dry::View::Part
  def name
    value.name.upcase
  end
end
```

## String conversion

When used to output to the template, a part will use it's value `#to_s` behavior (which you can override in your part classes):

```erb
<p><%= user %></p>
```

## Rendering partials

From a part, you can render a partial, with the part object included in the partial's own locals:

```ruby
class User < Dry::View::Part
  def info_box
    render(:info_box)
  end
end
```

This will render an `_info_box` partial template (via the standard [partial lookup rules](/gems/dry-view/templates/)) with the part still available as `user`.

You can also render such partials directly within templates:

```erb
<%= user.render(:info_box) %>
```

To make the part available by another name within the partial's cope, use the `as:` option:

```erb
<%= user.render(:info_box, as: :account) %>
```

You can also provide additional locals for the partial:

```erb
<%= user.render(:info_box, as: :account, title_label: "Your account") %>
```

## Building scopes

You may [build custom scopes](/gems/dry-view/scopes/) from within a part using `#_scope` (or `#scope` as a convenience, as long as the decorated value doesn't respond to `#scope`):

```ruby
class User < Dry::View::Part
  def info_box
    scope(:info_box, size: :large).render
  end
end
```

## Accessing the context

In your part classes, you can access the [context object](/gems/dry-view/context) as `#_context` (or `#context` as a convenience, as long the decorated value itself doesn't respond to `#context`). Parts also delegate missing methods to the context object (provided the decorated value itself doesn't respond to the method).

For example:

```ruby
class User < Dry::View::Part
  def avatar_url
    # asset_path is a method defined on the context object (in this case,
    # providing static asset URLs)
    value.avatar_url || asset_path("default-user-avatar.png")
  end
end
```

## Decorating part attributes

Your values may have their own attributes that you also want decorated as view parts. Declare these using `decorate` in your own view part classes:

```ruby
class UserPart < Dry::View::Part
  decorate :address
end
```

You can pass the same options to `decorate` as you do to [exposures](/gems/dry-view/exposures/), for example:

```ruby
class UserPart < Dry::View::Part
  decorate :address, as: :location
end
```

## Memoizing methods

A part object lives for the entirety of a view rendering, you can memoize expensive operations to ensure they only run once.

```ruby
class User < Dry::View::Part
  def bio_html
    @bio_html ||= rich_text_renderer.render(bio)
  end

  private

  def rich_text_renderer
    @rich_text_renderer ||= MyRenderer.new
  end
end
```

## Custom part class resolution

When defining your exposures, use the `as:` option to specify an alternative name or class for part decoration.

For singular values:

- `expose :article, as: :story` will look up a `Parts::Story` class
- `expose :article, as: Parts::MyArticle` will use the provided class

For arrays:

- `expose :articles, as: :stories` will look up `Parts::Stories` for decorating the array, and `Parts::Story` for decorating the elements
- `expose :articles, as: [:story_collection]` will look up `Parts::StoryCollection` for decorating the array, and `Parts::Article` for decorating the elements
- `expose :articles, as: [:story_collection, :story]` will look up `Parts::StoryCollection` for decorating the array, and `Parts::Story` for decorating the elements
- For the two `as:` structures above (with the names in the array), explicit classes can be provided instead of symbols, and they'll be used for decorating their respective items

All of these examples presume a configured `part_namespace` of `Parts`.

## Providing a custom part builder

To fully customize part decoration, you can provide a replacement part builder:

```ruby
class MyView < Dry::View
  config.part_builder = MyPartBuilder
end
```

Your part builder must conform to the following interface:

- `#initialize(namespace: nil, render_env: nil)`
- `#for_render_env(render_env)`
- `#call(name, value, **options)`

You can also inherit from `Dry::View::PartBuilder` and override any of its methods, if you want to customize just a particular aspect of the standard behavior.
