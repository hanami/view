# Lotus::View
View layer for Lotus

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
