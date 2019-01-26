# 0.6.0 / Unreleased

### Added

- [BREAKING] `Dry::View#call` now returns a `Dry::View::Rendered` instance, which carries both the rendered output (accessible via `#to_s` or `#to_str`) as well as all of the view's locals, wrapped in their view parts (accessible via `#locals` or individually via `#[]`) (timriley in [#72][pr72])
- [BREAKING] Added `Dry::View::PartBuilder` (renamed from `Dry::View::Decorator`), which resolves part classes from a namespace configured via View's `part_namespace` setting. A custom part builder can be specified via a View's `part_builder` setting. (timriley in [#80][pr80])
- [BREAKING] Context classes can now declare decorated attributes just like part classes, via `.decorate` class-level API. Context classes are now required to inherit from `Dry::View::Context`. `Dry::View::Context` provides a `#with` method for creating copies of itself while preserving the rendering details needed for decorated attributes to work (timriley in [#89][pr89] and [#91][pr91])
- Customizable _scope_ objects, which work like view parts, but instead of encapsulating a single value, they encapsulate a whole template or partial and all of its locals. Scopes can be created via `#scope` method in templates, parts, as well as scope classes themselves. Scope classes are resolved via a View's `scope_builder` setting, which defaults to an instance of `Dry::View::ScopeBuilder`.
- Added `inflector` setting to View, which is used by the part and scope builders to resolve classes for a given part or scope name. Defaults to `Dry::Inflector.new` (timriley in [#80][pr80] and [#90][pr90])
- Exposures can be sent to the layout template when defined with `layout: true` option (GustavoCaso in [#87][pr87])
- Exposures can be left undecorated by a part when defined with `decorate: false` option (timriley in [#88][pr88])
- Part classes have access to the current template format via a private `#_format` method (timriley in [#118][pr118])
- Added "Tilt adapter" layer, to ensure a rendering engine compatible with dry-view's features is being used. Added adapters for "haml" and "erb" templates to ensure that "hamlit-block" and "erbse" are required and used as engines (unlike their more common counterparts, both of these engines support the implicit block capturing that is a central part of dry-view rendering behaviour) (timriley in [#106][pr106])
- Added `renderer_engine_mapping` setting to View, which allows an explicit engine class to be provided for the rendering of a given type of template (e.g. `config.renderer_engine_mapping = {erb: Tilt::ErubiTemplate}`) (timriley in [#106][pr106])

### Changed

- [BREAKING] `Dry::View::Controller` renamed to `Dry::View` (timriley in [#115][pr115])
- [BREAKING] `Dry::View` `context` setting renamed to `default_context` (GustavoCaso in [#86][pr86])
- Exposure values are wrapped in their view parts before being made available as exposure dependencies (timriley in [#80][pr80])
- Exposures can access current context object through `context:` block or method parameter (timriley in [#119][pr119])
- Improved performance due to caching various lookups (timriley and GustavoCaso in [#97][pr97])
- `Part#inspect` output simplified to include only name and value (timriley in [#98][pr98])
- Attribute decoration in `Part` now achieved via a prepended module, which means it is possible to decorate an attribute provided by an instance method directly on the part class, which wasn't possible with the previous `method_missing`-based approach (timriley in [#110][pr110])
- `Part` classes can be initialized with missing `name:` and `rendering:` values, which can be useful for unit testing Part methods that don't use any rendering facilities (timriley in [#116][pr116])

### Fixed

- Preserve renderer options when chdir-ing (timriley in [889ac7b](https://github.com/dry-rb/dry-view/commit/889ac7b))

[Compare v0.5.3...v0.6.0](https://github.com/dry-rb/dry-view/compare/v0.5.3...v0.6.0)

[pr72]: https://github.com/dry-rb/dry-view/pull/72
[pr80]: https://github.com/dry-rb/dry-view/pull/80
[pr86]: https://github.com/dry-rb/dry-view/pull/86
[pr87]: https://github.com/dry-rb/dry-view/pull/87
[pr88]: https://github.com/dry-rb/dry-view/pull/88
[pr89]: https://github.com/dry-rb/dry-view/pull/89
[pr90]: https://github.com/dry-rb/dry-view/pull/90
[pr91]: https://github.com/dry-rb/dry-view/pull/91
[pr97]: https://github.com/dry-rb/dry-view/pull/97
[pr98]: https://github.com/dry-rb/dry-view/pull/98
[pr106]: https://github.com/dry-rb/dry-view/pull/106
[pr110]: https://github.com/dry-rb/dry-view/pull/110
[pr115]: https://github.com/dry-rb/dry-view/pull/115
[pr116]: https://github.com/dry-rb/dry-view/pull/116
[pr118]: https://github.com/dry-rb/dry-view/pull/118
[pr119]: https://github.com/dry-rb/dry-view/pull/119

# 0.5.4 / 2019-01-06 [YANKED 2019-01-18]

This version was yanked due to the release accidentally containing a batch of breaking changes from master.

### Fixed

- Preserve renderer options when chdir-ing (timriley in [889ac7b](https://github.com/dry-rb/dry-view/commit/889ac7b))

# 0.5.3 / 2018-10-22

### Added

- `renderer_options` setting for configuring tilt-based renderer (liseki in [#62][pr62])

### Changed

- Part objects wrap values more transparently, via added `#respond_to_missing?` (liseki in [#63][pr63])

[Compare v0.5.2...v0.5.3](https://github.com/dry-rb/dry-view/compare/v0.5.2...v0.5.3)

[pr62]: https://github.com/dry-rb/dry-view/pull/62
[pr63]: https://github.com/dry-rb/dry-view/pull/63

# 0.5.2 / 2018-06-13

### Changed

- Only truthy view part attributes are decorated (timriley)

[Compare v0.5.1...v0.5.2](https://github.com/dry-rb/dry-view/compare/v0.5.1...v0.5.2)

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
