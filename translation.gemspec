Gem::Specification.new do |s|
  s.name             = 'translation'
  s.summary          = 'Localize your app with YAML or GetText. Synchronize with your translators on Translation.io.'
  s.description      = 'Localize your app using either t(".keys") or _("source text") and type "rake translation:sync" to synchronize with your translators on Translation.io.'
  s.homepage         = 'https://translation.io'
  s.email            = 'contact@translation.io'
  s.version          = '1.17'
  s.date             = '2018-11-12'
  s.authors          = ['Michael Hoste', 'Aurelien Malisart']
  s.require_paths    = ["lib"]
  s.files            = Dir["lib/**/*"] + ['README.md']
  s.extra_rdoc_files = []
  s.has_rdoc         = false
  s.license          = "MIT"

  s.metadata = {
    "bug_tracker_uri"   => "https://github.com/translation/rails/issues",
    "changelog_uri"     => "https://github.com/translation/rails/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://translation.io/usage",
    "homepage_uri"      => "https://translation.io",
    "source_code_uri"   => "https://github.com/translation/rails"
  }

  s.add_dependency('gettext', '~> 3.2', '>= 3.2.5')

  s.add_development_dependency('rake')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('rspec', '~> 2.14')
  s.add_development_dependency('rails', '>= 4.1' )
end
