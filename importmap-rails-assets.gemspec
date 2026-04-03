require_relative 'lib/importmap_rails_assets/version'

Gem::Specification.new do |spec|
  spec.name    = 'importmap-rails-assets'
  spec.version = ImportmapRailsAssets::VERSION
  spec.authors = ['ursm']

  spec.summary  = 'Vendor arbitrary assets from pinned importmap packages'
  spec.homepage = 'https://github.com/ursm/importmap-rails-assets'
  spec.license  = 'MIT'

  spec.required_ruby_version = '>= 3.3'

  spec.files = Dir['lib/**/*', 'LICENSE', 'README.md']

  spec.add_dependency 'importmap-rails', '>= 2.0'
end
