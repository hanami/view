# Hanami::View
View layer for Hanami

## v1.3.0.beta1 - 2018-08-08
### Fixed
- [Ferdinand Niedermann] Ensure to set `:disable_escape` option only for Slim and don't let Tilt to emit a warning for other template engines.

## v1.2.0 - 2018-04-06

## v1.2.0.rc2 - 2018-04-06

## v1.2.0.rc1 - 2018-03-30

## v1.2.0.beta2 - 2018-03-23

## v1.2.0.beta1 - 2018-02-28

## v1.1.2 - 2018-04-10
### Fixed
- [Luca Guidi] Ensure to be able to use `exposures` even when they aren't duplicable objects

## v1.1.1 - 2018-02-27
### Added
- [Luca Guidi] Official support for Ruby: MRI 2.5

### Fixed
- [Alfonso Uceda] Ensure that `exposures` are properly overwritten for partials when `locals:` option is used

## v1.1.0 - 2017-10-25

## v1.1.0.rc1 - 2017-10-16

## v1.1.0.beta3 - 2017-10-04

## v1.1.0.beta2 - 2017-10-03
### Added
- [Luca Guidi] Added `Hanami::Layout#local` to safely access locals from layouts

## v1.1.0.beta1 - 2017-08-11
### Fixed
- [yjukaku] Raise `Hanami::View::UnknownRenderTypeError` when an argument different from `:template` or `:partial` is passed to `render`

## v1.0.1 - 2017-08-04
### Added
- [Luca Guidi] Compatibility with `haml` 5.0

## v1.0.0 - 2017-04-06

## v1.0.0.rc1 - 2017-03-31

## v1.0.0.beta2 - 2017-03-17
### Changed
- [Luca Guidi] Remove deprecated `Hanami::View::Rendering::LayoutScope#content`

## v1.0.0.beta1 - 2017-02-14
### Added
- [Luca Guidi] Official support for Ruby: MRI 2.4
- [Vladimir Dralo] Allow `View#initialize` to splat keyword arguments

## v0.8.0 - 2016-11-15
### Fixed
- [Luca Guidi] Ensure `Rendering::NullLocal` to work with HAML templates

### Changed
- [Luca Guidi] Official support for Ruby: MRI 2.3+ and JRuby 9.1.5.0+

## v0.7.0 - 2016-07-22
### Added
- [Luca Guidi] Introduced `#local` for views, layouts and templates. It allows to safely access locals without raising errors in case the referenced local is missing.

### Fixed
- [nessur] Find the correct partial in case of deeply nested templates.
- [Marcello Rocha] Ensure `Hanami::Presenter` to respect method visibility of wrapped object.
- [Luca Guidi] Ensure to use new registry when loading the framework

### Changed
– [Luca Guidi] Drop support for Ruby 2.0 and 2.1. Official support for JRuby 9.0.5.0+.
– [Luca Guidi] Deprecate `#content` in favor of `#local`.

## v0.6.1 - 2016-02-05
### Changed
- [Steve Hook] Preload partial templates in order to boost performances for partials rendering (2x faster)

### Fixed
- [Luca Guidi] Disable Slim autoescape to use `Hanami::View`'s feature

## v0.6.0 - 2016-01-22
### Changed
- [Luca Guidi] Renamed the project

## v0.5.0 - 2016-01-12
### Added
- [Luca Guidi] Added `Lotus::View::Configuration#default_encoding` to set the encoding for templates

### Fixed
- [Luca Guidi] Let exceptions to be raised as they occur in rendering context. This fixes misleading backtraces for exceptions.
- [Martin Rubi] Raise a `Lotus::View::MissingTemplateError` when rendering a missing partial from a template
- [Luca Guidi] Fix for `template.erb is not valid US-ASCII (Encoding::InvalidByteSequenceError)` when system encoding is not set

### Changed
- [Liam Dawson] Introduced `Lotus::View::Error` and let all the framework exceptions to inherit from it.

## v0.4.4 - 2015-09-30
### Added
- [Luca Guidi] Autoescape for layout helpers.

## v0.4.3 - 2015-07-10
### Fixed
- [Farrel Lifson] Force partial finder to be explicit when to templates have the same name.

## v0.4.2 - 2015-06-23
### Fixed
- [Tom Kadwill] Ensure views to use methods defined by the associated layout.

## v0.4.1 - 2015-05-22
### Added
- [Luca Guidi] Introduced `#content` to render optional contents in a different context (eg. a view sets a page specific javascript in the application template footer).

## v0.4.0 - 2015-03-23
### Changed
- [Luca Guidi] Autoescape concrete and virtual methods from presenters
- [Luca Guidi] Autoescape concrete and virtual methods from views

### Fixed
- [Tom Kadwill] Improve error message for undefined method in view
- [Luca Guidi] Ensure that layouts will include modules from `Configuration#prepare`

## v0.3.0 - 2014-12-23
### Added
- [Trung Lê] When duplicate the framework, also duplicate `Presenter`
- [Benny Klotz] Introduced `Scope#class`, `#inspect`, `LayoutScope#class` and `#inspect`
- [Alfonso Uceda Pompa & Trung Lê] Introduced `Configuration#prepare`
- [Luca Guidi] Implemented "respond to" logic for `Lotus::View::Scope` (`respond_to?` and `respond_to_missing?`)
- [Luca Guidi] Implemented "respond to" logic for `Lotus::Layout` (`respond_to?` and `respond_to_missing?`)
- [Jeremy Stephens] Allow view concrete methods that accept a block to be invoked from templates
- [Peter Suschlik] Implemented "respond to" logic for `Lotus::Presenter` (`respond_to?` and `respond_to_missing?`)
- [Luca Guidi] Official support for Ruby 2.2

### Changed
- [Alfonso Uceda Pompa] Raise an exception when a layout doesn't have an associated template

### Fixed
- [Luca Guidi] Ensure that concrete methods in layouts are available in templates
- [Luca Guidi] Ensure to associate the right layout to a view in case fo duplicated framework
- [Luca Guidi] Safe override of Ruby's top level methods in Scope. (Eg. use `select` from a view, not from `::Kernel`)

## v0.2.0 - 2014-06-23
### Added
- [Luca Guidi] Introduced `Configuration#duplicate`
- [Luca Guidi] Introduced `Configuration#layout` to define the layout that all the views will use
- [Luca Guidi] Introduced `Configuration#load_paths` to define several sources where to lookup for templates
- [Luca Guidi] Introduced `Configuration#root` to define the root path where to find templates
- [Luca Guidi] Introduced `Lotus::View::Configuration`
- [Grant Ammons] Allow view concrete methods with arity > 0 to be invoked from templates
- [Luca Guidi] Official support for Ruby 2.1

### Changed
- [Luca Guidi] `Rendering::TemplatesFinder` now look recursively for templates, starting from the root.
- [Luca Guidi] Removed `View.layout=`
- [Luca Guidi] Removed `View.root=`

### Fixed
- [Luca Guidi] Ensure outermost locals to not shadow innermost inside templates/partials

## v0.1.0 - 2014-03-23
### Added
- [Luca Guidi] Allow custom rendering policy via `Action#render` override. This bypasses the template lookup and rendering.
- [Luca Guidi] Introduced `Lotus::Presenter`
- [Luca Guidi] Introduced templates rendering from templates and layouts
- [Luca Guidi] Introduced partials rendering from templates and layouts
- [Luca Guidi] Introduced layouts support
- [Luca Guidi] Introduced `Lotus::View.load!` as entry point to load views and templates
- [Luca Guidi] Allow to setup template name via `View.template`
- [Luca Guidi] Rendering context also considers locals passed to the constructor
- [Luca Guidi] Introduced `View.format` as DSL to declare which format to handle
- [Luca Guidi] Introduced view subclasses as way to handle different formats (mime types)
- [Luca Guidi] Introduced multiple templates per each View
- [Luca Guidi] Implemented basic rendering with templates
- [Luca Guidi] Official support for Ruby 2.0
