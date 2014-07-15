Gem::Specification.new do |s|
  s.name             = 'translation'
  s.summary          = 'translation.io connector'
  s.description      = 'translation.io connector'
  s.homepage         = 'http://rails.translation.io'
  s.email            = 'contact@translation.io'
  s.version          = '0.1'
  s.date             = '2014-03-28'
  s.authors          = ['Aurelien Malisart', 'Michaël Hoste']
  s.require_paths    = ["lib"]
  s.files            = Dir["lib/**/*"] + ["README.rdoc"]
  s.extra_rdoc_files = ["README.rdoc"]
  s.has_rdoc         = false
  s.license          = "MIT"

  s.add_dependency('gettext', '>= 3.1.2')

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rails')
  s.add_development_dependency('haml')
end
