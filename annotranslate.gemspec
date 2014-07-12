# -*- encoding: utf-8 -*-
HERE = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(HERE)
$LOAD_PATH.unshift File.join(HERE, 'lib')

require 'version'
require 'date'

Gem::Specification.new do |s|
  s.name = %q{annotranslate}
  s.version = AnnoTranslate::VERSION
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Greg Williams"]
  s.date = Date.today.to_s
  s.description = %q{Rails plugin which provides annotation of translatable strings}
  s.email = %q{greg.williams@atomicobject.com}
  s.files = [
    "README.md",
    "Rakefile",
    "LICENSE",
    "init.rb",
    "install.rb",
    "uninstall.rb"
  ] + Dir["./lib/**"] + Dir["./tasks/**"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/atomicobject/annotranslate}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib", "tasks"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Rails plugin which provides annotation of translatable strings}
  s.test_files = [
    # NEED SOME!!!
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2
  end
end
