# 0.5.1 / 2018-02-20

### Added

- Exposures are inherited from parent view controller classes (GustavoCaso)

[Compare v0.5.0...v0.5.1](https://github.com/dry-rb/dry-view/compare/v0.5.0...v0.5.1)

# 0.5.0 / 2018-01-23

### Added

- Support for parts with decorated attributes (timriley + GustavoCaso)
- Ability to easily create another part instance via `Part#new` (GustavoCaso)

[Compare v0.4.0...v0.5.0](https://github.com/dry-rb/dry-view/compare/v0.4.0...v0.5.0)

# 0.4.0 / 2017-11-01

### Added

- Raise a helpful error when trying to render a template or partial that cannot be found (GustavoCaso)
- Raise a helpful error when trying to call a view controller with no template configured (timriley)
- Allow a default to be specified for pass-through exposures with the `default:` option (GustavoCaso)

### Changed

- [BREAKING] Exposures specify the input data they require using keyword arguments. This includes support for providing default values (via the keyword argument) for keys that are missing from the input data (GustavoCaso)
- Allow `Dry::View::Part` instances to be created without explicitly passing a `renderer`. This is helpful for unit testing view parts that don't need to render anything (dNitza)
- Partials can be nested within additional sub-directories by rendering them their relative path as their name, e.g. `render(:"foo/bar")` will look for a `foo/_bar.html.slim` template within the normal template lookup paths (timriley)

# 0.3.0 / 2017-05-14

This release reintroduces view parts in a more helpful form. You can provide your own custom view part classes to encapsulate your view logic, as well as a  decorator for custom, shared behavior arouund view part wrapping.

### Changed

- [BREAKING] Partial rendering in templates requires an explicit `render` method call instead of method_missing behaviour usinig the partial's name (e.g. `<%= render :my_partial %>` instead of `<%= my_partial %>`)

### Added

- Wrap all values passed to the template in `Dry::View::Part` objects
- Added a `decorator` config to `Dry::View::Controller`, with a default `Dry::View::Decorator` that wraps the exposure values in `Dry::View::Part` objects (as above). Provide your own part classes by passing an `:as` option to your exposures, e.g. `expose :user, as: MyApp::UserPart`

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
