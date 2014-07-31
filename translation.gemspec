Gem::Specification.new do |s|
  s.name             = 'translation'
  s.summary          = 'translation.io connector'
  s.description      = 'translation.io connector'
  s.homepage         = 'http://rails.translation.io'
  s.email            = 'contact@translation.io'
  s.version          = '0.4'
  s.date             = '2014-07-31'
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
  s.add_development_dependency('haml')
  s.add_development_dependency('slim')
end
