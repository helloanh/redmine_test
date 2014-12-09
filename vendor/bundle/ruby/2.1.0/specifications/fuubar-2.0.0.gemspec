# -*- encoding: utf-8 -*-
# stub: fuubar 2.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "fuubar"
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Nicholas Evans", "Jeff Kreeftmeijer", "jfelchner"]
  s.date = "2014-08-07"
  s.description = "the instafailing RSpec progress bar formatter"
  s.email = ["jeff@kreeftmeijer.nl"]
  s.extra_rdoc_files = ["README.md", "LICENSE"]
  s.files = ["LICENSE", "README.md"]
  s.homepage = "https://github.com/jeffkreeftmeijer/fuubar"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--charset", "UTF-8"]
  s.rubygems_version = "2.4.3"
  s.summary = "the instafailing RSpec progress bar formatter"

  s.installed_by_version = "2.4.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rspec>, ["~> 3.0"])
      s.add_runtime_dependency(%q<ruby-progressbar>, ["~> 1.4"])
    else
      s.add_dependency(%q<rspec>, ["~> 3.0"])
      s.add_dependency(%q<ruby-progressbar>, ["~> 1.4"])
    end
  else
    s.add_dependency(%q<rspec>, ["~> 3.0"])
    s.add_dependency(%q<ruby-progressbar>, ["~> 1.4"])
  end
end
