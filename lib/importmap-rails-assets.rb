require 'importmap-rails'
require 'importmap/packager'

require_relative 'importmap_rails_assets/version'
require_relative 'importmap_rails_assets/packager_extension'
require_relative 'importmap_rails_assets/engine'

Importmap::Packager.prepend ImportmapRailsAssets::PackagerExtension
