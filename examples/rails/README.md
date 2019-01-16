# dry-view example Rails app

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

The following files/folders are specific to the dry-view integration:

- Setup lines in `config/application.rb`
- `app/views/`
- `app/templates/`

This is the minimum viable integration. There is much more that can be done to improve ergonomics and integrate dry-view with the Rails development experience.
