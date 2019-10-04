---
title: Exposures
layout: gem-single
name: dry-view
---

Define _exposures_ within your view to declare and prepare the values to be passed to the template, decorated as [parts](/gems/dry-view/parts/).

An exposure can take a block:

```ruby
class MyView < Dry::View
  expose :users do
    user_repo.listing
  end
end
```

Or refer to an instance method:

```ruby
class MyView < Dry::View
  expose :users

  private

  def users
    user_repo.listing
  end
end
```

Or allow a matching value from the input data to pass through to the view:

```ruby
class MyView < Dry::View
  # With no matching instance method, passes the `users:` argument provided to
  # `#call` straight to the template
  expose :users
end
```

## Accessing input data

If your exposure needs to work with input data (i.e. the arguments passed to the view’s `#call`), specify these as keyword arguments for your exposure block. Make this a _required_ keyword argument if you require the data passed to the view’s `#call`:

```ruby
class MyView < Dry::View
  expose :users do |page:|
    user_repo.listing(page: page)
  end
end
```

The same applies to instance methods acting as exposures:

```ruby
class MyView < Dry::View
  expose :users

  private

  def users(page:)
    user_repo.listing(page: page)
  end
end
```

### Specifying defaults

To make input data optional, provide a default value for the keyword argument (either `nil` or something more meaningful):

```ruby
class MyView < Dry::View
  expose :users do |page: 1|
    user_repo.listing(page: page)
  end
end
```

If your exposure passes through input data directly, use the `default:` option:

```ruby
class MyView < Dry::View
  # With no matching instance method, passes the `users:` argument to `#call`
  # straight to the template
  expose :users, default: []
end
```

## Accessing the context

To access the [context object](/gems/dry-view/context) from an exposure, include a `context:` keyword parameter:

```ruby
expose :articles do |context:|
  article_repo.listing_for_user(context.current_user)
end
```

## Depending on other exposures

Sometimes you may want to prepare data for other exposures to use. You can _depend_ on another exposure by naming it as a positional argument for your exposure block or method.

```ruby
class MyView < Dry::View::Controller
  expose :users do |page:|
    user_repo.listing(page: page)
  end

  expose :user_count do |users|
    users.to_a.length
  end
end
```

In this example, the `user_count` exposure has access to the value of the `users` value since it named the exposure as a positional argument. The `users` value is at this point will already be decorated by its [part object](/gems/dry-view/parts).

Exposure dependencies (positional arguments) and input data (keyword arguments) can also be provided together:

```ruby
expose :user_count do |users, count_title: "Admins count"|
  "#{count_title}: #{users.to_a.length}"
end
```

## Layout exposures

Exposure values are made available only to the template by default. To make an exposure available to the layout, specify the `layout: true` option:

```ruby
expose :users, layout: true do |page:|
  user_repo.listing(page: page)
end
```

## Private exposures

You can create _private exposures_ that are not passed to the template. This is helpful if you have an exposure that others will depend on, but is not otherwise needed in the template. Use `private_expose` for this:

```ruby
class MyView < Dry::View::Controller
  private_expose :user_listing do
    user_repo.listing
  end

  expose :users do |user_listing|
    # does something with user_listing
  end

  expose :user_count do |user_listing|
    # also needs to work with user_listing
  end
end
```

In this example, only `users` and `user_count` will be passed to the template.

## Undecorated exposures

You can create an exposure whose value is not decorated by a part. This may be helpful when your exposure returns a simpler "primitive" object that requires no extra behaviour, like a number or a string. To do this, pass the `decorate: false` option.

```
expose :page_number, decorate: false
```
