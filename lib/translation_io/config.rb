module TranslationIO
  class Config
    attr_accessor :api_key, :locales_path, :yaml_locales_path
    attr_accessor :source_locale, :target_locales
    attr_accessor :endpoint
    attr_accessor :verbose
    attr_accessor :test

    attr_accessor :domains, :text_domain

    attr_accessor :ignored_key_prefixes
    attr_accessor :ignored_source_paths
    attr_accessor :ignored_source_files
    attr_accessor :forced_source_paths

    attr_accessor :source_formats
    attr_accessor :erb_source_formats
    attr_accessor :haml_source_formats
    attr_accessor :slim_source_formats

    attr_accessor :localization_key_prefixes
    attr_accessor :disable_gettext
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
      self.ignored_source_paths      = ['vendor/', 'tmp/']
      self.ignored_source_files      = [] # Files not parsed for GetText entries
      self.forced_source_paths       = []

      self.source_formats            = ['rb', 'ruby', 'rabl']
      self.erb_source_formats        = ['erb', 'inky']
      self.haml_source_formats       = ['haml', 'mjmlhaml']
      self.slim_source_formats       = ['slim', 'mjmlslim']

      self.localization_key_prefixes = []
      self.disable_gettext           = false
      self.charset                   = 'UTF-8'
      self.metadata_path             = File.join('config', 'locales', '.translation_io')

      self.pot_msgid_bugs_address    = 'contact@translation.io'
      self.pot_package_name          = File.basename(Dir.pwd)
      self.pot_package_version       = '1.0'
      self.pot_copyright_holder      = File.basename(Dir.pwd)
      self.pot_copyright_year        = Date.today.year
      self.text_domain               = TEXT_DOMAIN
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

      # remove ignored files
      file_paths = file_paths - ignored_source_files

      # check for forced_source_paths
      if forced_source_paths.any?
        # only output forced paths by filtering entire list and collecting
        orig_file_paths = file_paths.dup
        file_paths = []
        forced_source_paths.each do |forced_source_path|
          file_paths += orig_file_paths.select { |file_path| file_path.start_with?(forced_source_path)}
        end
      else
        # remove ignored paths
        ignored_source_paths.each do |ignored_source_path|
          file_paths = file_paths.select { |file_path| !file_path.start_with?(ignored_source_path) }
        end
      end

      file_paths
    end

    def to_s
      "API Key: #{api_key} | Languages: #{source_locale} => [#{target_locales.join(', ')}]"
    end

    def set_domain(domain=nil)
      if domain.nil?
        self.text_domain = TEXT_DOMAIN
      else
        self.text_domain = domain[:name]
        self.api_key = domain[:api_key]
        self.source_locale = domain[:source_locale]
        self.target_locales = domain[:target_locales]
        self.forced_source_paths = domain[:folders]
        avoid_folders = (domain_folders - [forced_source_paths]).flatten
        self.ignored_source_paths = ['vendor/', 'tmp/'] + avoid_folders
      end
    end

  private
    def domain_folders
      self.domains.nil? ? [] : self.domains.map{|d| d[:folders]}
    end
  end
end
