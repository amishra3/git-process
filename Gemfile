source 'http://rubygems.org'

group :default do
  gem 'octokit', '~> 1.24' # GitHub API
  gem 'netrc', '~> 0.7.7'
  gem 'json', '~> 1.8'
  gem 'trollop', '~> 2.1' # CLI options parser
  gem 'highline', '~> 1.7' # user CLI interaction
  gem 'addressable', '~> 2.3.5' # URI processing. 2.4 Changes URI parsing

  # lock down external dependency
  gem 'faraday', '0.8.9'
end

group :development do
  gem 'rake'#, '~> 0.9'
  gem 'yard'#, '~> 0.8' # documentation generator
  gem 'redcarpet'#, '~> 2'
end

group :test do
  gem 'rspec', '~> 2.99'
  gem 'webmock', '~> 1.17', '< 1.20' # network mocking. 1.20 changes the API
  gem 'rugged', '~> 0.18.0.gh.de28323'
  gem 'climate_control', '~> 0.0.3'
end
