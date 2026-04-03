module ImportmapRailsAssets
  class Engine < ::Rails::Engine
    initializer 'importmap_rails_assets.assets' do |app|
      next unless app.config.respond_to?(:assets)

      config_path = Rails.root.join('config/assets.yml')
      next unless config_path.exist?

      config = YAML.safe_load_file(config_path) || {}

      dirs = config.each_value.flat_map {|mappings|
        mappings.values.map {|dest| File.dirname(dest) }
      }.uniq

      dirs.each do |dir|
        app.config.assets.paths << Rails.root.join(dir)
      end
    end
  end
end
