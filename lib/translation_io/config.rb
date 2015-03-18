module TranslationIO
  class Config
    attr_accessor :api_key, :locales_path, :yaml_locales_path
    attr_accessor :source_locale, :target_locales
    attr_accessor :endpoint
    attr_accessor :verbose
    attr_accessor :test
    attr_accessor :ignored_key_prefixes
    attr_accessor :localization_key_prefixes
    attr_accessor :charset
    attr_accessor :metadata_path

    attr_accessor :pot_msgid_bugs_address
    attr_accessor :pot_package_name
    attr_accessor :pot_package_version
    attr_accessor :pot_copyright_holder
    attr_accessor :pot_copyright_year

    def initialize
      self.locales_path              = File.join('config', 'locales', 'gettext')
      self.yaml_locales_path         = File.join('config', 'locales')
      self.source_locale             = :en
      self.target_locales            = []
      self.endpoint                  = 'https://translation.io/api'
      self.verbose                   = 1
      self.test                      = false
      self.ignored_key_prefixes      = []
      self.localization_key_prefixes = []
      self.charset                   = 'UTF-8'
      self.metadata_path             = File.join('config', 'locales', '.translation_io')

      self.pot_msgid_bugs_address = 'contact@translation.io'
      self.pot_package_name       = File.basename(Dir.pwd)
      self.pot_package_version    = '1.0'
      self.pot_copyright_holder   = File.basename(Dir.pwd)
      self.pot_copyright_year     = Date.today.year
    end

    def pot_path
      File.join(locales_path, "#{TEXT_DOMAIN}.pot")
    end

    def yaml_file_paths
      I18n.load_path.select do |p|
        File.exist?(p) && (File.extname(p) == '.yml' || File.extname(p) == '.yaml')
      end
    end

    def source_files
      Dir['**/*.{rb,erb,ruby,rabl}'].select do |p|
        !p.start_with?('vendor/') && !p.start_with?('tmp/')
      end
    end

    def haml_source_files
      Dir['**/*.{haml}'].select do |p|
        !p.start_with?('vendor/') && !p.start_with?('tmp/')
      end
    end

    def slim_source_files
      Dir['**/*.{slim}'].select do |p|
        !p.start_with?('vendor/') && !p.start_with?('tmp/')
      end
    end

    def to_s
      "#{api_key} - #{source_locale} => #{target_locales.join(' + ')}"
    end
  end
end
