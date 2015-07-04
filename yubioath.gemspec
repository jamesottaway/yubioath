# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'yubioath'
  spec.version       = '0.1.1'
  spec.authors       = ['James Ottaway']
  spec.email         = ['yubioath@james.ottaway.io']
  spec.summary       = 'Securely manage your 2FA tokens using your Yubikey NEO'
  spec.homepage      = 'https://github.com/jamesottaway/yubioath'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'bindata', '~> 2.1'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
end
