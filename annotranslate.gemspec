# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{annotranslate}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Greg Williams"]
  s.date = %q{2014-06-17}
  s.description = %q{Rails plugin which provides annotation of translatable strings}
  s.email = %q{greg.williams@atomicobject}
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    "README",
    "Rakefile",
    "VERSION.yml",
    "lib/annotranslate.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/atomicobject/annotranslate}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Rails plugin which provides annotation of translatable strings}
  s.test_files = [
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
