Gem::Specification.new do |s|
  s.name             = 'translation'
  s.summary          = 'Rails translation made _("simple") with YAML and GetText.'
  s.description      = 'Translation.io allows you to localize Rails applications using either t(".keys") or _("free text"). Just type "rake translation:sync" to synchronize with your translators, and let them translate online with our interface.'
  s.homepage         = 'http://translation.io'
  s.email            = 'contact@translation.io'
  s.version          = '1.0.0'
  s.date             = '2015-01-08'
  s.authors          = ['Aurelien Malisart', 'Michael Hoste']
  s.require_paths    = ["lib"]
  s.files            = Dir["lib/**/*"] + ['README.md']
  s.extra_rdoc_files = []
  s.has_rdoc         = false
  s.license          = "MIT"

  s.add_dependency('gettext', '>= 3.1.2')

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rails')
end
