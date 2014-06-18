## v0.2.0
### Jun 23, 2014

5a5ed1b 2014-06-18 **Luca Guidi** Depend on lotus-utils ~> 0.2

d7858df 2014-06-18 **Luca Guidi** Ensure to handle correctly the namespace for views, when it's configured as nil

8f9e876 2014-06-18 **Luca Guidi** Renamed Lotus::View methods: .duplicate => .dupe, .generate => .duplicate

199c1d6 2014-06-11 **Luca Guidi** Introducing Lotus::View.generate as shortcut for .duplicate and .configure

d3e65d9 2014-06-11 **Luca Guidi** Ensure lazy loading and correct namespace of the layout class when using configuration's "layout" DSL

850c9b9 2014-06-11 **Luca Guidi** Specify different scenario for template name in a standalone application

6199419 2014-06-06 **Luca Guidi** Ensure to return the correct template name for namespaced views

71d502f 2014-06-06 **Luca Guidi** Ensure independent configurations between the framework, the views and its children. Lotus::View::Dsl.root now internally uses the configuration.

dd0ec4c 2014-06-06 **Luca Guidi** Lazily load layout for Configuration. This mechanism solves eventual race conditions between the loading of the framework and the application.

d2e0775 2014-06-05 **Luca Guidi** [breaking] Lotus::View can be safely duplicated. Moved views and layout registries into Configuration. Configuration is now able to duplicated and (un)load itself. Layouts can be looked up in a given Ruby namespace.

a619bd2 2014-06-05 **Luca Guidi** Implemented Lotus::View::Configuration#views and #layouts

e4e892e 2014-06-04 **Luca Guidi** [breaking] Removed Lotus::View's class accessor for root, in favor of the API of Lotus::View::Configuration

1aa68c6 2014-06-04 **Luca Guidi** [breaking] Removed Lotus::View's class accessor for layout, in favor of the API of Lotus::View::Configuration

da9bee4 2014-06-04 **Luca Guidi** Implemented Lotus::View::Configuration#layout

da31e3e 2014-06-04 **Luca Guidi** Implemented Lotus::View::Configuration#load_paths

1471cdd 2014-06-03 **Luca Guidi** Introduced Lotus::View::Configuration with a bare minimum behavior

425c79e 2014-05-21 **Grant Ammons** Support arguments for methods inside templates

d4d407b 2014-05-10 **Luca Guidi** Support Ruby 2.1.2

593f1a5 2014-04-07 **Luca Guidi** Ensure outermost locals to not shadow innermost inside templates/partials. Closes #3

## v0.1.0
### Mar 23, 2014

af70191 2014-03-22 **Luca Guidi** Introduced Lotus::View::MissingFormatError in order to force a rendering context to specify the requested format (mime type)

320f322 2014-03-22 **Luca Guidi** Changed signature of Lotus::View.render: it now accepts only a context for the view

9d5de63 2014-03-21 **Luca Guidi** Test with other engines than ERb, HAML in this case.

a5ade35 2014-03-21 **Luca Guidi** Erubis is no longer a dependency.

257e342 2014-03-21 **Luca Guidi** Performance: prefer `Hash#fetch(key) { default }`, over `#fetch(key, default)`.

426eaf7 2014-03-21 **Luca Guidi** Allow custom rendering policies. Views can override #render and decide how to return the output.

b2759f8 2014-03-18 **Luca Guidi** Lotus::View::Layout => Lotus::Layout

c0c04a8 2014-03-17 **Luca Guidi** Remove private method for Presenter: #object

74ca485 2014-03-13 **Luca Guidi** Introduced Lotus::Presenter

0ee9c10 2014-03-13 **Luca Guidi** Render partial from a layout

dc4a74f 2014-03-12 **Luca Guidi** Support for Tilt 2.0

728fe70 2014-02-20 **Luca Guidi** Added Lotus::View#locals

11c7e5a 2013-08-08 **Luca Guidi** Don't use global class vars.

570a20c 2013-08-07 **Luca Guidi** Scope templates discovery to registered engines

4b45b11 2013-08-06 **Luca Guidi** Added support for layouts.

96a2c66 2013-08-02 **Luca Guidi** Allow templates to be rendered from templates.

ba5acdc 2013-08-01 **Luca Guidi** Allow partials to be rendered from templates.

04474d4 2013-08-01 **Luca Guidi** Render template in the Lotus::View::Rendering::Scope context

d108767 2013-08-01 **Luca Guidi** Freeze at subclasses level too

04a3093 2013-08-01 **Luca Guidi** Let views to specify relative template filename

e7c832d 2013-08-01 **Luca Guidi** Lotus::View::Rendering::Template => Lotus::View::Template

f603ea9 2013-08-01 **Luca Guidi** Rework

5df49f1 2013-07-23 **Luca Guidi** Removed unnecessary indirection

683741c 2013-07-22 **Luca Guidi** Views can now transparently inheriths variables from locals, in order to reuse them.

3a31f63 2013-07-19 **Luca Guidi** Removed templates as class variable for views: introduced a registry for runtime resolution

f27e19f 2013-07-18 **Luca Guidi** WIP rendering resolver

05e1d8c 2013-07-18 **Luca Guidi** Allow views inheritance.

8236523 2013-07-18 **Luca Guidi** Refactoring: Engine is not relevant, let Tilt to deal with it. View has multiple templates. Intoduced DSL for format. Introduced resolver for runtime rendering. Dependency injection. :tophat:

f7f3d25 2013-07-17 **Luca Guidi** Extracted Lotus::View::Template::Finder

11d3c47 2013-07-15 **Luca Guidi** Initial mess
