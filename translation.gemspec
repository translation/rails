Gem::Specification.new do |s|
  s.name             = 'translation'
  s.summary          = 'Rails translation made _("simple") with YAML and GetText.'
  s.description      = 'Rails translation made _("simple") with YAML and GetText. Localize your app using either t(".keys") or _("free text") and type "rake translation:sync" to synchronize with your translators.'
  s.homepage         = 'https://translation.io'
  s.email            = 'contact@translation.io'
  s.version          = '1.13'
  s.date             = '2018-02-19'
  s.authors          = ['Aurelien Malisart', 'Michael Hoste']
  s.require_paths    = ["lib"]
  s.files            = Dir["lib/**/*"] + ['README.md']
  s.extra_rdoc_files = []
  s.has_rdoc         = false
  s.license          = "MIT"

  s.add_dependency('gettext', '>= 3.2.5')

  s.add_development_dependency('rake',                      '~> 10.3'  )
  s.add_development_dependency('rspec',                     '>= 2.14.1')
  s.add_development_dependency('rails',                     '~> 4.1'   )
  s.add_development_dependency('simplecov'                             )
  s.add_development_dependency('codeclimate-test-reporter', '~> 1.0.0' )
end
