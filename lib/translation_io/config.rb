module TranslationIO
  class Config
    attr_accessor :api_key, :locales_path
    attr_accessor :source_locale, :target_locales
    attr_accessor :endpoint
    attr_accessor :verbose
    attr_accessor :test

    def initialize
      self.locales_path   = File.join('config', 'locales', 'gettext')
      self.source_locale  = :en
      self.target_locales = []
      self.endpoint       = 'api.translation.io/api'
      self.verbose        = 1
      self.test           = false
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
      paths = Dir['**/*.{rb,erb,html.erb,xml.erb}'].select do |p|
        !p.start_with?('vendor/') && !p.start_with?('tmp/')
      end

      paths += Dir['tmp/translation/*.rb']

      paths
    end

    def yaml_locales_path
      'config/locales'
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
