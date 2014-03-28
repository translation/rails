Gem::Specification.new do |s|
  s.name                      = 'translation'
  s.summary                   = 'rails.translation.io connector'
  s.description               = 'rails.translation.io connector'
  s.homepage                  = 'http://rails.translation.io'
  s.version                   = '0.1'
  s.date                      = '2014-03-28'
  s.authors                   = ['Aurelien Malisart', 'Michaël Hoste']
  s.require_paths             = ["lib"]
  s.files                     = Dir["lib/**/*"] + ["README.rdoc"]
  s.extra_rdoc_files          = ["README.rdoc"]
  s.has_rdoc                  = false
  s.rubygems_version          = "1.6.2"
  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6")

  s.add_dependency('gettext', '~> 3.1.1')
end
