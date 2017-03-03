Pod::Spec.new do |s|
  s.name         = 'Moderator'
  s.version      = '0.4.0-beta'
  s.summary      = 'A simple, modular command line argument parser in Swift.'
  s.description  = 'A simple, modular command line argument parser in Swift. '
  s.homepage     = 'https://github.com/kareman/Moderator'
  s.license      = { type: 'MIT', file: 'LICENSE.txt' }
  s.author = { 'Kare Morstol' => 'kare@nottoobadsoftware.com' }
  s.source = { git: 'https://github.com/kareman/Moderator.git', tag: s.version.to_s }
  s.source_files = 'Sources/*.swift'
  s.osx.deployment_target = '10.10'
end