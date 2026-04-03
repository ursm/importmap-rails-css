require 'net/http'
require 'yaml'
require 'fileutils'

module ImportmapRailsAssets
  module PackagerExtension
    def download(package, url)
      super

      version = extract_package_version_from(url)&.delete_prefix('@')
      return unless version

      asset_mappings = load_asset_mappings(package)
      return if asset_mappings.empty?

      asset_mappings.each do |source, dest|
        download_asset(package, version, source, dest)
      end
    end

    def remove(package)
      super

      load_asset_mappings(package).each_value do |dest|
        path = Pathname.new(dest)
        FileUtils.rm_f(path)
      end
    end

    private

    def load_asset_mappings(package)
      config_path = Pathname.new('config/assets.yml')
      return {} unless config_path.exist?

      config = YAML.safe_load_file(config_path) || {}
      config[package] || {}
    end

    def download_asset(package, version, source, dest)
      uri = URI("https://cdn.jsdelivr.net/npm/#{package}@#{version}/#{source}")

      response = Net::HTTP.get_response(uri)
      return unless response.is_a?(Net::HTTPSuccess)

      dest_path = Pathname.new(dest)
      FileUtils.mkdir_p dest_path.dirname

      File.binwrite(dest_path, response.body)

      puts %(Downloading "#{package}/#{source}" to #{dest})
    end
  end
end
