source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development, :test do
  gem 'rake'
  gem 'rspec',                   :require => false
  gem 'mocha',                   :require => false
  gem 'puppet-lint',             :require => false
  gem 'puppetlabs_spec_helper',  :require => false
  gem 'beaker',                  :require => false
  gem 'beaker-rspec',            :require => false
  gem 'serverspec',              :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
