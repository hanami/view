# hanami-view example Rails app

## Setup

Set up the project:

```
./bin/setup
```

Run `./bin/rails console` and create some sample records:

```
Article.create(title: "Hello world")
```

To see the rendered views, run `./bin/rails server` and visit http://localhost:3000.

## Integration

The following files/folders are specific to the hanami-view integration:

- Setup lines in `config/application.rb`
- `app/views/`
- `app/templates/`

n.b. this is a minimal integration to demonstrate how hanami-view can work with Rails; there's plenty more that could be done to deepen the integration, flesh out the view-related features, and improve the overall experience.

The ideal integration would come via a hanami-view-rails integration gem. See [this open issue][issue] for more details.

[issue]: https://github.com/dry-rb/dry-view/issues/114
