# -*- encoding: utf-8 -*-
# stub: ps 0.0.8 ruby lib

Gem::Specification.new do |s|
  s.name = "ps"
  s.version = "0.0.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Tal Atlas"]
  s.date = "2012-08-09"
  s.description = "A ruby utility for interacting with the unix tool 'ps'"
  s.email = ["me@tal.by"]
  s.homepage = "https://github.com/Talby/ps"
  s.rubyforge_project = "ps"
  s.rubygems_version = "2.4.3"
  s.summary = "A ruby wrapper for the unix tool 'ps'"

  s.installed_by_version = "2.4.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_runtime_dependency(%q<ansi>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<ansi>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<ansi>, [">= 0"])
  end
end
