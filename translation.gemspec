Gem::Specification.new do |s|
  s.name             = 'translation'
  s.summary          = 'Rails translation made _("simple") with YAML and GetText.'
  s.description      = 'Rails translation made _("simple") with YAML and GetText.'
  s.homepage         = 'http://translation.io'
  s.email            = 'contact@translation.io'
  s.version          = '0.9.6'
  s.date             = '2014-10-28'
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
