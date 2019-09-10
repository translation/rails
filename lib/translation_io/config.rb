module TranslationIO
  class Config
    attr_accessor :api_key
    attr_accessor :source_locale
    attr_accessor :target_locales
    attr_accessor :endpoint
    attr_accessor :metadata_path
    attr_accessor :verbose
    attr_accessor :test

    attr_accessor :disable_yaml

    attr_accessor :yaml_locales_path
    attr_accessor :ignored_key_prefixes
    attr_accessor :localization_key_prefixes
    attr_accessor :yaml_line_width

    attr_accessor :disable_gettext

    attr_accessor :gettext_object_delegate

    attr_accessor :locales_path

    attr_accessor :ignored_source_paths
    attr_accessor :ignored_source_files

    attr_accessor :parsed_gems

    attr_accessor :source_formats
    attr_accessor :erb_source_formats
    attr_accessor :haml_source_formats
    attr_accessor :slim_source_formats

    attr_accessor :text_domain
    attr_accessor :bound_text_domains
    attr_accessor :charset

    attr_accessor :pot_msgid_bugs_address
    attr_accessor :pot_package_name
    attr_accessor :pot_package_version
    attr_accessor :pot_copyright_holder
    attr_accessor :pot_copyright_year

    def initialize

      #######
      # Global options
      #######

      self.api_key        = ''
      self.source_locale  = :en
      self.target_locales = []
      self.endpoint       = 'https://translation.io/api'
      self.metadata_path  = File.join('config', 'locales', '.translation_io')
      self.verbose        = 1
      self.test           = false

      #######
      # YAML options
      #######

      self.disable_yaml = false

      # YAML directory
      self.yaml_locales_path = File.join('config', 'locales')

      # Ignored YAML key prefixes (like 'will_paginate.')
      self.ignored_key_prefixes = []

      # Cf. https://github.com/translation/rails#custom-localization-key-prefixes
      self.localization_key_prefixes = []

      # Define max line width of generated YAML files:
      # Can be nil (default behaviour of Ruby version), -1 (no wrapping) or positive integer (wrapping)
      # Cf. https://github.com/translation/rails/issues/19
      self.yaml_line_width = nil

      #######
      # GetText options
      #######

      self.disable_gettext = false

      # Cf. https://github.com/translation/rails#gettext-object-class-monkey-patching
      self.gettext_object_delegate = true

      # GetText directory for PO and MO files
      self.locales_path = File.join('config', 'locales', 'gettext')

      # These paths and files will not be parsed for GetText entries
      self.ignored_source_paths = ['vendor/', 'tmp/', 'node_modules/', 'logs/', '.git/']
      self.ignored_source_files = []

      # These gems will be parsed by GetText (use gem names)
      self.parsed_gems = []

      # Extensions for rb/erb/haml/slim file parsers
      self.source_formats      = ['rb', 'ruby', 'rabl']
      self.erb_source_formats  = ['erb', 'inky']
      self.haml_source_formats = ['haml', 'mjmlhaml']
      self.slim_source_formats = ['slim', 'mjmlslim']

      # 'text_domain' will be synced (name of .po/.mo files)
      # 'bound_text_domains' will be read during execution (in that priority order)
      self.text_domain        = 'app'
      self.bound_text_domains = ['app']
      self.charset            = 'UTF-8'

      # POT header informations
      self.pot_msgid_bugs_address = 'contact@translation.io'
      self.pot_package_name       = File.basename(Dir.pwd)
      self.pot_package_version    = '1.0'
      self.pot_copyright_holder   = File.basename(Dir.pwd)
      self.pot_copyright_year     = Date.today.year
    end

    def pot_path
      File.join(locales_path, "#{text_domain}.pot")
    end

    def yaml_file_paths
      I18n.load_path.select do |p|
        File.exist?(p) && (File.extname(p) == '.yml' || File.extname(p) == '.yaml')
      end
    end

    def source_files
      source_files_for_formats(source_formats)
    end

    def erb_source_files
      source_files_for_formats(erb_source_formats)
    end

    def haml_source_files
      source_files_for_formats(haml_source_formats)
    end

    def slim_source_files
      source_files_for_formats(slim_source_formats)
    end

    def source_files_for_formats(formats)
      file_paths = Dir["**/*.{#{formats.join(',')}}"]

      # Add gems that need to be parsed by GetText
      parsed_gems.each do |gem_name|
        if Gem.loaded_specs[gem_name]
          gem_path   = Gem.loaded_specs[gem_name].full_gem_path
          file_paths += Dir["#{gem_path}/**/*.{#{formats.join(',')}}"]
        end
      end

      # remove ignored files
      file_paths = file_paths - ignored_source_files

      # remove ignored paths
      ignored_source_paths.each do |ignored_source_path|
        file_paths = file_paths.select { |file_path| !file_path.start_with?(ignored_source_path) }
      end

      file_paths
    end

    def to_s
      "API Key: #{api_key} | Languages: #{source_locale} => [#{target_locales.join(', ')}]"
    end
  end
end
