Gem::Specification.new do |s|
  s.name          = 'translation'
  s.summary       = 'Localize your app with YAML or GetText. Synchronize with your translators on Translation.io.'
  s.description   = 'Localize your app using either t(".keys") or _("source text") and type "rake translation:sync" to synchronize with your translators on Translation.io.'
  s.homepage      = 'https://translation.io'
  s.email         = 'contact@translation.io'
  s.version       = '1.41'
  s.authors       = ['Michael Hoste', 'Aurelien Malisart']
  s.license       = "MIT"
  s.require_paths = ["lib"]
  s.files         = Dir["lib/**/*"] + ['README.md']

  s.metadata = {
    "homepage_uri"      => "https://translation.io/rails",
    "source_code_uri"   => "https://github.com/translation/rails",
    "bug_tracker_uri"   => "https://github.com/translation/rails/issues",
    "changelog_uri"     => "https://github.com/translation/rails/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://translation.io/docs/guide-to-translate-your-rails-applications"
  }

  s.add_runtime_dependency 'gettext', '~> 3.2', '>= 3.2.5', '<= 3.4.9'

  s.add_development_dependency 'rake',      '~> 12.0'
  s.add_development_dependency 'simplecov', '~> 0.11'
  s.add_development_dependency 'rspec',     '~> 3.0'
  s.add_development_dependency 'rails',     '>= 4.1'
end
