# 0.2.2 / 2017-01-31

### Changed

- Make input passthrough exposures (when there is no block or matching instance metod) return nil instead of raise in the case of a missing input key (timriley)

# 0.2.1 / 2017-01-30

### Fixed

- Exposure blocks now have access to the view controller instance when they're called (timriley)

# 0.2.0 / 2017-01-30

This release is a major reorientation for dry-view, and it should allow for more natural, straightforward template authoring.

### Changed

- [BREAKING] `Dry::View::Layout` renamed to `Dry::View::Controller`. The "view controller" name better represents this object's job: to  (timriley)
- [BREAKING] `Dry::View::Controller`'s `name` setting is replaced by `template`, which also supports falsey values to disable layout rendering entirely (timriley)
- [BREAKING] `Dry::View::Controller`'s `formats` setting is replaced by `default_format`, which expects a simple string or symbol. The default value is `:html`. (timriley)
- [BREAKING] `Dry::View::Controller`'s `root` setting is replaced by `paths`, which can now accept an array of one or more directories. These will be searched for templates in order, with the first match winning (timriley)
- [BREAKING] `Dry::View::Controller`'s `scope` setting is removed and replaced by `context`, which will be made available to all templates rendered from a view controller (layouts and partials inculded), not just the layout (timriley)
- [BREAKING] View parts have been replaced by a simple `Scope`. Data passed to the templates can be accessed directly, rather than wrapped up in a view part. (timriley)
- [BREAKING] With view parts removed, partials can only be rendered by top-level method calls within templates (timriley)
- Ruby version 2.1.0 is now the earliest supported version (timriley)

### Added

- Will render templates using any Tilt-supported engine, based on the template's final file extension (e.g. `hello.html.slim` will use Slim). For thread-safety, be sure to explicitly require any engine gems you intend to use. (timriley)
- `expose` (and `expose_private`) `Dry::View::Controller` class methods allow you to more easily declare and prepare the data for your template (timriley)
- Added `Dry::View::Scope`, which is the scope used for rendering templates. This includes the data from the exposures along with the context object (timriley)

# 0.1.1 / 2016-07-07

### Changed

- Wrap `page` object exposed to layout templates in a part object, so it offers behaviour that is consistent with the part objects that template authors work with on other templates (timriley)
- Render template content first, before passing that content to the layout. This makes "content_for"-style behaviours possible, where the template stores some data that the layout can then use later (timriley)
- Configure default template encoding to be UTF-8, fixing some issues with template rendering on deployed sites (gotar)

# 0.1.0 / 2016-03-28

### Added

– `Dry::View::Layout` supports multiple view template formats. Configure format/engine pairs (e.g. `{html: :slim, text: :erb}`) on the `formats` setting. The first format becomes the default. Request specific formats when calling the view, e.g. `my_view.call(format: :text)`.

### Changed

– Extracted from rodakase and renamed to dry-view. `Rodakase::View` is now `Dry::View`.
