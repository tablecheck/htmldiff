Gem::Specification.new do |s|
  s.name = %q{htmldiff}
  s.version = '1.0.0'
  s.authors = ['Nathan Herald']
  s.email = %q{nathan@myobie.com}
  s.description = %q{HTML diffs of text (borrowed from a wiki software I no longer remember)}
  s.summary = %q{HTML diffs of text (borrowed from a wiki software I no longer remember)}
  s.homepage = %q{http://github.com/myobie/htmldiff}
  s.license = 'MIT'
  
  s.add_development_dependency 'rspec', '~> 3.6'
  s.add_development_dependency 'rake', '~> 12.1'

  s.files         = Dir.glob('lib/**/*') + %w[LICENSE README]
  s.test_files    = Dir.glob('spec/**/*')
  s.require_paths = ['lib']
end
