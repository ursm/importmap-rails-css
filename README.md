# importmap-rails-assets

Vendor arbitrary assets (CSS, fonts, images, etc.) from packages pinned with [importmap-rails](https://github.com/rails/importmap-rails).

## Installation

Add to your Gemfile:

```ruby
gem 'importmap-rails-assets'
```

## Usage

Define asset mappings in `config/assets.yml`. Each key is an npm package name (as pinned in your importmap), and the value is a hash of source paths within the package to local destination paths:

```yaml
tom-select:
  dist/css/tom-select.bootstrap5.css: vendor/assets/stylesheets/tom-select.css

flatpickr:
  dist/flatpickr.css: vendor/assets/stylesheets/flatpickr.css
  dist/themes/dark.css: vendor/assets/stylesheets/flatpickr-dark.css
```

Then pin the package as usual:

```
$ bin/importmap pin flatpickr
Pinning "flatpickr" to vendor/javascript/flatpickr.js via download from https://ga.jspm.io/npm:flatpickr@4.6.13/dist/flatpickr.js
Downloading "flatpickr/dist/flatpickr.css" to vendor/assets/stylesheets/flatpickr.css
Downloading "flatpickr/dist/themes/dark.css" to vendor/assets/stylesheets/flatpickr-dark.css
```

`bin/importmap update` and `bin/importmap pristine` also download assets in the same way.

`bin/importmap unpin` removes the corresponding asset files as well.

Packages without an entry in `config/assets.yml` are silently skipped.

## License

MIT
