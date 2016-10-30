lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'create_ap/version'

Gem::Specification.new do |s|
  s.name          = 'create_ap'
  s.version       = CreateAp::VERSION
  s.author        = 'oblique'
  s.email         = 'psyberbits@gmail.com'

  s.summary       = 'Create NATed AP'
  s.homepage      = 'https://github.com/oblique/create_ap'
  s.license       = 'MIT'

  s.files         = ['LICENSE'] + Dir.glob('bin/**/*') + Dir.glob('lib/**/*')
  s.executables   = ['create_ap']
  s.require_paths = ['lib']
  s.platform      = 'linux'

  s.add_development_dependency 'bundler', '~> 1.13'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'minitest', '~> 5.0'

  s.add_dependency 'ipaddress', '~> 0.8'
end
