source 'https://rubygems.org'

# Exact specification is here, as we cannot declare a :git dependency in ydim.gemspec
gem "dbi", :git => 'https://github.com/ngiger/ruby-dbi'
gem "odba",:git => 'https://github.com/ngiger/odba.git'
gem 'ydim',:git => 'https://github.com/ngiger/ydim'
gem "sbsm",    :git => 'https://github.com/ngiger/sbsm'
gem "htmlgrid", :git => 'https://github.com/ngiger/htmlgrid'

gem "bundler"
gem "hpricot"
gem "mail"
gem "needle"
gem "rake"
gem "rclconf"
gem 'deprecated', '= 2.0.1'

group :test do
  gem "minitest"
  gem "watir"
  gem 'page-object'
  gem "rspec"
  gem "flexmock"
  gem "test-unit"
end
group :debugger do
	if RUBY_VERSION.match(/^1/)
		gem 'pry-debugger'
	else
		gem 'pry-byebug'
    gem 'pry-doc'
	end
end
