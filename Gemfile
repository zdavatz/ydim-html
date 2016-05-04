source 'https://rubygems.org'

# Exact specification is here, as we cannot declare a :git dependency in ydim.gemspec
gem "odba",:git => 'https://github.com/ngiger/odba.git'

gem "dbi", :git => 'https://github.com/ngiger/ruby-dbi'

gem 'ydim',:git => 'https://github.com/ngiger/ydim'

gem "bundler"
gem "hpricot"
gem "mail"
gem "needle"
gem "rake"
gem "rclconf"
gem 'deprecated', '= 2.0.1'
#gem "sbsm",    :git => 'https://github.com/ngiger/sbsm'
#gem "htmlgrid", :git => 'https://github.com/ngiger/htmlgrid'
gem "sbsm",    :path => '/mnt/src/sbsm'
gem "htmlgrid", :path => '/mnt/src/htmlgrid'

group :test do
  gem "minitest"
  gem "selenium"
  gem "watir"
  gem 'watir-webdriver'
  gem 'page-object'
end
group :debugger do
  gem "flexmock"
  gem "test-unit"
  gem "rspec"
	if RUBY_VERSION.match(/^1/)
		gem 'pry-debugger'
	else
		gem 'pry-byebug'
    gem 'pry-doc'
	end
end
