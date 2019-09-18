
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "httply/version"

Gem::Specification.new do |spec|
  spec.name          = "httply"
  spec.version       = Httply::VERSION
  spec.authors       = ["Sebastian Johnsson"]
  spec.email         = ["sebastian.johnsson@gmail.com"]

  spec.summary       = %q{Httply - lightweight Faraday wrapper}
  spec.description   = %q{Httply is a lightweight wrapper around Faraday to support automatic randomization of proxies and user agents, amongst other things.}
  spec.homepage      = "https://github.com/SebastianJ/httply"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  
  spec.add_dependency "faraday",                ">= 0.15.4"  
  spec.add_dependency "faraday_middleware",     ">= 0.13.1"
  spec.add_dependency "agents",                 ">= 0.1.4"

  spec.add_development_dependency "bundler",    "~> 1.17"
  spec.add_development_dependency "rake",       "~> 10.0"
  spec.add_development_dependency "rspec",      "~> 3.0"
  
  spec.add_development_dependency "pry",        "~> 0.12.2"
  
  spec.add_development_dependency "nokogiri",   "~> 1.10"
  spec.add_development_dependency "multi_xml",  "~> 0.6.0"
end
