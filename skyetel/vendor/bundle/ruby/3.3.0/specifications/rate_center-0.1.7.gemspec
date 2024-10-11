# -*- encoding: utf-8 -*-
# stub: rate_center 0.1.7 ruby lib

Gem::Specification.new do |s|
  s.name = "rate_center".freeze
  s.version = "0.1.7".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/somleng/rate_center/blob/main/CHANGELOG.md", "homepage_uri" => "https://github.com/somleng/rate_center", "source_code_uri" => "https://github.com/somleng/rate_center" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Wilkie".freeze]
  s.bindir = "exe".freeze
  s.date = "2024-10-11"
  s.email = ["dwilkie@gmail.com".freeze]
  s.homepage = "https://github.com/somleng/rate_center".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0.0".freeze)
  s.rubygems_version = "3.5.16".freeze
  s.summary = "A collection of useful data about NANPA Rate Centers.".freeze

  s.installed_by_version = "3.5.16".freeze if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<multi_xml>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<ox>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<faraday>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rack>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<countries>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<ostruct>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rubyzip>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<csv>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<geocoder>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<logger>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<fiddle>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rubocop-rails-omakase>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rubocop-rspec>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rubocop-performance>.freeze, [">= 0".freeze])
end
