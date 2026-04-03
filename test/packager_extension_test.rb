require 'test_helper'

class PackagerExtensionTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir
    @importmap_path = File.join(@dir, 'config', 'importmap.rb')

    FileUtils.mkdir_p File.join(@dir, 'config')
    File.write @importmap_path, ''

    @vendor_js = File.join(@dir, 'vendor', 'javascript')

    @packager = Importmap::Packager.new(@importmap_path, vendor_path: @vendor_js)
  end

  def teardown
    FileUtils.remove_entry @dir
  end

  def test_download_copies_assets_from_config
    write_assets_yml(
      'flatpickr' => {
        'dist/flatpickr.css'    => 'vendor/stylesheets/flatpickr.css',
        'dist/themes/dark.css'  => 'vendor/stylesheets/flatpickr-dark.css'
      }
    )

    stub_js_download
    stub_cdn('flatpickr', '4.6.13', 'dist/flatpickr.css', body: '.flatpickr {}')
    stub_cdn('flatpickr', '4.6.13', 'dist/themes/dark.css', body: '.dark {}')

    Dir.chdir(@dir) do
      @packager.download('flatpickr', 'https://ga.jspm.io/npm:flatpickr@4.6.13/dist/flatpickr.js')
    end

    assert_equal '.flatpickr {}', File.read(File.join(@dir, 'vendor/stylesheets/flatpickr.css'))
    assert_equal '.dark {}', File.read(File.join(@dir, 'vendor/stylesheets/flatpickr-dark.css'))
  end

  def test_download_skips_when_no_config_entry
    write_assets_yml({})

    stub_js_download

    Dir.chdir(@dir) do
      @packager.download('lodash', 'https://ga.jspm.io/npm:lodash@4.17.21/lodash.js')
    end
  end

  def test_download_skips_when_no_config_file
    stub_js_download

    Dir.chdir(@dir) do
      @packager.download('lodash', 'https://ga.jspm.io/npm:lodash@4.17.21/lodash.js')
    end
  end

  def test_download_skips_when_cdn_fails
    write_assets_yml(
      'pkg' => {'dist/style.css' => 'vendor/stylesheets/pkg.css'}
    )

    stub_js_download
    stub_request(:get, 'https://cdn.jsdelivr.net/npm/pkg@1.0.0/dist/style.css')
      .to_return(status: 404)

    Dir.chdir(@dir) do
      @packager.download('pkg', 'https://ga.jspm.io/npm:pkg@1.0.0/index.js')
    end

    refute File.exist?(File.join(@dir, 'vendor/stylesheets/pkg.css'))
  end

  def test_remove_deletes_assets
    write_assets_yml(
      'flatpickr' => {
        'dist/flatpickr.css'   => 'vendor/stylesheets/flatpickr.css',
        'dist/themes/dark.css' => 'vendor/stylesheets/flatpickr-dark.css'
      }
    )

    Dir.chdir(@dir) do
      FileUtils.mkdir_p File.join(@dir, 'vendor/stylesheets')
      File.write File.join(@dir, 'vendor/stylesheets/flatpickr.css'), '.flatpickr {}'
      File.write File.join(@dir, 'vendor/stylesheets/flatpickr-dark.css'), '.dark {}'
      File.write @importmap_path, %(pin "flatpickr" # @4.6.13\n)

      @packager.remove('flatpickr')
    end

    refute File.exist?(File.join(@dir, 'vendor/stylesheets/flatpickr.css'))
    refute File.exist?(File.join(@dir, 'vendor/stylesheets/flatpickr-dark.css'))
  end

  def test_remove_succeeds_when_no_config_entry
    Dir.chdir(@dir) do
      File.write @importmap_path, %(pin "lodash" # @4.17.21\n)

      @packager.remove('lodash')
    end
  end

  def test_download_handles_binary_files
    write_assets_yml(
      'pkg' => {'dist/font.woff2' => 'vendor/fonts/pkg.woff2'}
    )

    binary_content = "\x00\x01\x02\xFF".b

    stub_js_download
    stub_cdn('pkg', '1.0.0', 'dist/font.woff2', body: binary_content)

    Dir.chdir(@dir) do
      @packager.download('pkg', 'https://ga.jspm.io/npm:pkg@1.0.0/index.js')
    end

    assert_equal binary_content, File.binread(File.join(@dir, 'vendor/fonts/pkg.woff2'))
  end

  private

  def write_assets_yml(config)
    File.write File.join(@dir, 'config', 'assets.yml'), YAML.dump(config)
  end

  def stub_js_download
    stub_request(:get, /ga\.jspm\.io/).to_return(body: '// js')
  end

  def stub_cdn(package, version, path, body:)
    stub_request(:get, "https://cdn.jsdelivr.net/npm/#{package}@#{version}/#{path}")
      .to_return(body: body)
  end
end
