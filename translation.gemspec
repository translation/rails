Gem::Specification.new do |s|
  s.name             = 'translation'
  s.summary          = 'Localize your app with YAML or GetText. Synchronize with your translators on Translation.io.'
  s.description      = 'Localize your app using either t(".keys") or _("source text") and type "rake translation:sync" to synchronize with your translators on Translation.io.'
  s.homepage         = 'https://translation.io'
  s.email            = 'contact@translation.io'
  s.version          = '1.18'
  s.authors          = ['Michael Hoste', 'Aurelien Malisart']
  s.license          = "MIT"
  s.require_paths    = ["lib"]
  s.files            = Dir["lib/**/*"] + ['README.md']

  s.metadata = {
    "bug_tracker_uri"   => "https://github.com/translation/rails/issues",
    "changelog_uri"     => "https://github.com/translation/rails/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://translation.io/usage",
    "homepage_uri"      => "https://translation.io",
    "source_code_uri"   => "https://github.com/translation/rails"
  }

  s.add_dependency             'gettext',   '~> 3.2', '>= 3.2.5'

  s.add_development_dependency 'rake',      '~> 12.0'
  s.add_development_dependency 'simplecov', '~> 0.11'
  s.add_development_dependency 'rspec',     '~> 2.14'
  s.add_development_dependency 'rails',     '>= 4.1', '< 7.0'
end
