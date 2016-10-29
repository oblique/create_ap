Gem::Specification.new do |s|
  s.name        = 'create_ap'
  s.version     = '1.0.0.dev'
  s.license     = 'MIT'
  s.summary     = 'Create NATed AP'
  s.author      = 'oblique'
  s.email       = 'psyberbits@gmail.com'
  s.homepage    = 'https://github.com/oblique/create_ap'
  s.files       = ['LICENSE'] + Dir.glob('bin/**/*') + Dir.glob('lib/**/*')
  s.executables = ['create_ap']
  s.platform    = 'linux'

  s.add_dependency('ipaddress', '~> 0.8')
end
