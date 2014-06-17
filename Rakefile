require 'rake'
require 'rake/testtask'
require 'rdoc/task'

desc 'Generate documentation for AnnoTranslate plugin'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'AnnoTranslate - annotate translations for i18n-based rails apps'
  rdoc.options << '--line-numbers' << '--inline-source' << '--webcvs=https://github.com/atomicobject/annotranslate/tree/master'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

def git(cmd)
  safe_system("git " + cmd)
end

def safe_system(cmd)
  if !system(cmd)
    puts "Failed: #{cmd}"
    exit
  end
end
