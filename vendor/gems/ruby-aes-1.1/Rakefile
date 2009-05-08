require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'fileutils'

include FileUtils

@name = 'ruby-aes'
@version = '1.1'
@native = false

@lib = "lib/#{@name}"
@ext = "ext/#{@name}"
@ext_o = 'aes_alg.o'
@ext_so = "aes_alg.#{Config::CONFIG['DLEXT']}"

RDOC_OPTS = ['--quiet',
    '--title', 'ruby-aes reference',
    '--opname', 'index.html',
    '--exclude', 'ext',
    '--line-numbers',
    '--main', 'README',
    '--inline-source']

CLEAN.include [
    '**/.*.sw?', '*.gem', '.config', '**/.DS_Store',
    "#{@ext}/#{@ext_so}", "#{@ext}/#{@ext_o}",
    "#{@ext}/Makefile", "#{@ext}/aes_cons.h", "#{@ext}/mkmf.log",
    "#{@lib}/aes_alg.rb", "#{@lib}/aes_cons.rb", "#{@lib}/aes_gencons.rb"
]

SPEC = Gem::Specification.new do |s|
    s.name = @name
    s.version = @version
    s.platform = Gem::Platform::RUBY
    s.has_rdoc = true
    s.rdoc_options += RDOC_OPTS
    s.extra_rdoc_files = ['README', 'CHANGELOG', 'COPYING']
    s.summary = 'ruby-aes is an implementation of the Rijndael algorithm (AES)'
    s.description = s.summary
    s.author = 'Alex Boussinet'
    s.email = 'alex.boussinet@gmail.com'
    s.homepage = "http://#{@name}.rubyforge.org"
    s.rubyforge_project = @name
    s.test_files = FileList['test/test_*.rb']
    s.require_paths = ['lib']
#    s.bindir = 'bin'
    s.files = %w(CHANGELOG COPYING README Rakefile) +
        Dir.glob('{doc,examples,lib,test}/**/*')
end

def task_gem
    desc 'Build the gem'
    Rake::GemPackageTask.new(SPEC) do |p|
        p.need_tar = true
        p.gem_spec = SPEC
    end
end

Dir.glob('extras/*').each do |project|
    desc "Specify the project to use"
    task File.basename(project).to_sym do |t|
        @type = t.name

        @gem_name = "#{@name}-#{@type}"
        SPEC.name = @gem_name
        SPEC.files += [ "#{@lib}/aes_alg.rb", "#{@lib}/aes_cons.rb" ]
        task_gem
    end
end

desc "Specify the project to use"
task :cext do |t|
    @type = t.name

    @gem_name = "#{@name}-#{@type}"
    SPEC.name = @gem_name
    SPEC.require_paths += ['ext']
    if @native
        SPEC.files += ["#{@ext}/#{@ext_so}"]
        SPEC.platform = Gem::Platform::CURRENT
    else
        SPEC.files += [ "#{@ext}/aes_alg.c", "#{@ext}/extconf.rb", "#{@ext}/aes_cons.h" ]
        SPEC.extensions = "#{@ext}/extconf.rb"
    end
    task_gem
end
desc "Use the native version of cext"
task :native do
    @native = true
    Rake::Task[:cext].invoke
end

task :prepare do
    if @type == 'cext'
        Dir.chdir(@ext) do
            ruby 'aes_gencons.rb'
            if @native
                ruby 'extconf.rb'
                sh(PLATFORM =~ /win32/ ? 'nmake' : 'make')
            end
        end
    else
        cp "extras/#{@type}/aes_alg.rb", "#{@lib}/"
        cp "extras/#{@type}/aes_gencons.rb", "#{@lib}/"
        Dir.chdir(@lib) do
            ruby 'aes_gencons.rb'
            rm_f 'aes_gencons.rb'
        end
    end
end

task :package => [:clean, :prepare, :rerdoc]

task :default do
    STDERR.puts <<-EOM
You must call rake with one of this task as first param:
    normal
    optimized
    table1
    table2
    unroll1
    unroll2
    cext
    native (imply cext)
    EOM
end

desc 'Run all the tests'
Rake::TestTask.new do |t|
    t.libs << "test"
    t.test_files = FileList['test/test_*.rb']
    t.verbose = true
end

desc 'Build the documentation'
Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = 'doc/rdoc'
    rdoc.options += RDOC_OPTS
    rdoc.main = 'README'
    rdoc.rdoc_files.add ['README', 'CHANGELOG', 'COPYING', 'lib/**/*.rb']
end

desc 'Install the package'
task :install do |t|
    sh %{sudo gem install pkg/#{@gem_name}}
end

desc 'Uninstall the package'
task :uninstall do
    sh %{sudo gem uninstall #{@gem_name}}
end
