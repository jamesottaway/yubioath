# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'yubioath'
  spec.version       = '1.0.0'
  spec.authors       = ['James Ottaway']
  spec.email         = ['yubioath@james.ottaway.io']
  spec.summary       = 'A mostly-complete Ruby implementation of the YubiOATH applet protocol'
  spec.homepage      = 'https://github.com/jamesottaway/yubioath'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'bindata', '~> 2.1'
end
