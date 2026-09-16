# For puppetcore, set GEM_SOURCE_PUPPETCORE = 'https://rubygems-puppetcore.puppet.com'
gemsource_default = ENV['GEM_SOURCE'] || 'https://rubygems.org'
gemsource_puppetcore = if ENV['PUPPET_FORGE_TOKEN']
  'https://rubygems-puppetcore.puppet.com'
else
  ENV['GEM_SOURCE_PUPPETCORE'] || gemsource_default
end
source gemsource_default

def location_for(place_or_version, fake_version = nil, opts = {})
  git_url_regex = %r{\A(?<url>(https?|git)[:@][^#]*)(#(?<branch>.*))?}
  file_url_regex = %r{\Afile:\/\/(?<path>.*)}

  if place_or_version && (git_url = place_or_version.match(git_url_regex))
    [fake_version, { git: git_url[:url], branch: git_url[:branch], require: false }].compact
  elsif place_or_version && (file_url = place_or_version.match(file_url_regex))
    ['>= 0', { path: File.expand_path(file_url[:path]), require: false }]
  else
    [place_or_version, { require: false }.merge(opts)]
  end
end

group :development do
  gem "json", '= 2.6.1',                         require: false if Gem::Requirement.create(['>= 3.1.0', '< 3.1.3']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "json", '= 2.6.3',                         require: false if Gem::Requirement.create(['>= 3.2.0', '< 4.0.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "racc", '~> 1.4.0',                        require: false if Gem::Requirement.create(['>= 2.7.0', '< 3.0.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "deep_merge", '~> 1.2.2',                  require: false
  gem "voxpupuli-puppet-lint-plugins", '~> 7.0', require: false
  gem "facterdb", '~> 2.1',                      require: false if Gem::Requirement.create(['< 3.0.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "facterdb", '~> 3.0',                      require: false if Gem::Requirement.create(['>= 3.0.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "metadata-json-lint", '~> 4.0',            require: false
  gem "json-schema", '< 5.1.1',                  require: false
  gem "rspec-puppet-facts", '~> 4.0',            require: false if Gem::Requirement.create(['< 3.0.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "rspec-puppet-facts", '~> 5.0',            require: false if Gem::Requirement.create(['>= 3.0.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "dependency_checker", '~> 1.0.0',          require: false
  gem "parallel_tests", '= 3.12.1',              require: false
  gem "pry", '~> 0.10',                          require: false
  gem "simplecov-console", '~> 0.9',             require: false
  gem "puppet-debugger", '~> 1.6',               require: false
  gem "rubocop", '~> 1.50.0',                    require: false
  gem "rubocop-performance", '= 1.16.0',         require: false
  gem "rubocop-rspec", '= 2.19.0',               require: false
  gem "rb-readline", '= 0.5.5',                  require: false, platforms: [:mswin, :mingw, :x64_mingw]
  gem "bigdecimal", '< 3.2.2',                   require: false, platforms: [:mswin, :mingw, :x64_mingw]
  gem "ruby-pwsh",                               require: false
end
group :development, :release_prep do
  gem "puppet-strings", '~> 4.0',         require: false
  gem "puppetlabs_spec_helper", '~> 9.0', require: false
  gem "puppet-blacksmith", '~> 7.0',      require: false
end
group :system_tests do
  # 2.7.0 is the first release whose matrix_from_metadata_v3 knows about Puppet 9: it gates
  # the collection on PUPPET_FORGE_TOKEN and emits the '~> 9.0' spec_matrix entry. Floored
  # unconditionally at 2.8, since --collection-platform-exclude (which ci.yml/nightly.yml pass
  # unconditionally) only exists from 2.8.0 onward -- older 2.x releases hard-fail with
  # OptionParser::InvalidOption instead of degrading gracefully. pdk-templates' own
  # Gemfile.erb only ever generates a single unconditional puppet_litmus line here; the
  # PUPPET_FORGE_TOKEN-gated split this module used to carry was a hand-maintained
  # deviation, not something the template emits.
  gem "puppet_litmus", '~> 2.8',   require: false, platforms: [:ruby, :x64_mingw]
  gem "CFPropertyList", '< 3.0.7', require: false, platforms: [:mswin, :mingw, :x64_mingw]
  gem "serverspec", '~> 2.41',     require: false
end


gems = {}

puppet_version = ENV.fetch('PUPPET_GEM_VERSION', nil)
facter_version = ENV.fetch('FACTER_GEM_VERSION', nil)
hiera_version = ENV.fetch('HIERA_GEM_VERSION', nil)

# Puppet 9.0.0 is a released gem on the standard puppetcore source (confirmed:
# puppetlabs-windows_eventlog#100's CI resolves `puppet (9.0.0)` from
# gemsource_puppetcore with no PUPPET_GEM_SOURCE set) -- no separate internal/Twingate
# source or prerelease-specific version matching is needed for it anymore.
gems['puppet'] = location_for(puppet_version, nil, { source: gemsource_puppetcore })
gems['facter'] = location_for(facter_version, nil, { source: gemsource_puppetcore })
gems['hiera'] = location_for(hiera_version, nil, {}) if hiera_version

gems.each do |gem_name, gem_params|
  gem gem_name, *gem_params
end

# Evaluate Gemfile.local and ~/.gemfile if they exist
extra_gemfiles = [
  "#{__FILE__}.local",
  File.join(Dir.home, '.gemfile'),
]

extra_gemfiles.each do |gemfile|
  if File.file?(gemfile) && File.readable?(gemfile)
    eval(File.read(gemfile), binding)
  end
end
# vim: syntax=ruby
