# hanami-view example dry-system/sinatra app

## Setup

Set up the project:

```
bundle
```

To see the rendered views, run `bundle exec rackup` and visit http://localhost:9292.

## Integration

The following files/folders are specific to the hanami-view integration:

- View helper methods in `lib/example_app/web.rb`
- `lib/example_app/view.rb`
- `lib/example_app/view/`
- `lib/example_app/views/`
- `web/templates/`

n.b. this is a minimal integration to demonstrate how hanami-view can fit within an app using dry-system and a web front-end like Sinatra; there's plenty more that could be done to flesh out the view-related features and improve the overall experience.
