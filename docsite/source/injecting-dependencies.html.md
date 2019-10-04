---
title: Injecting dependencies
layout: gem-single
name: dry-view
---

Most views will need access to other parts of your application to prepare values for the view. Since views follow the "functional object" pattern (local state for config and collaborators only, with any variable data passed to `#call`), it’s easy to use dependency injection to make your application’s objects available to your views.

To set up the injection manually, accept arguments to `#initialize` and assign them to instance variables.

```ruby
class MyView < Dry::View
  attr_reader :user_repo

  def initialize(user_repo:)
    @user_repo = user_repo
    super()
  end

  expose :users do
    user_repo.listing
  end
end
```

Or if your app uses [dry-system](/gems/dry-system) or [dry-auto_inject](/gems/dry-auto_inject), this is even less work:

```ruby
# Require the auto-injector module for your app's container
require "my_app/import"

class MyView < Dry::View
  include MyApp::Import["user_repo"]

  expose :users do
    user_repo.listing
  end
end
```
