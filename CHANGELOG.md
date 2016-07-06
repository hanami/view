# 0.1.1 / 2016-07-07

### Changed

- Configure default template encoding to be UTF-8, fixing some issues with template rendering on deployed sites (gotar)

# 0.1.0 / 2016-03-28

### Added

– `Dry::View::Layout` supports multiple view template formats. Configure format/engine pairs (e.g. `{html: :slim, text: :erb}`) on the `formats` setting. The first format becomes the default. Request specific formats when calling the view, e.g. `my_view.call(format: :text)`.

### Changed

– Extracted from rodakase and renamed to dry-view. `Rodakase::View` is now `Dry::View`.
