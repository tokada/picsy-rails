source 'http://rubygems.org'
ruby "2.0.0"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0.rc1'

group :production do
  gem 'pg'
end
group :development, :test do
  gem 'sqlite3'
end

gem "less-rails"
gem "less-rails-bootstrap"

group :assets do
  if RUBY_PLATFORM =~ /mingw/
    gem "therubyracer", :path => '../therubyracer-0.11.0beta1-x86-mingw32'
  else
    gem 'therubyracer'
  end
end

#gem 'twitter-bootstrap-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.0.1'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'devise', :github => 'plataformatec/devise', :branch => 'rails4' # 認証
gem 'protected_attributes'
gem 'omniauth-twitter' # Twitter認証（Devise用）

gem 'state_machine' # 状態遷移

group :development do
  gem 'rails-erd'
end

group :test do
  gem 'rspec-rails'
  # gem 'spork-rails', git: 'git://github.com/koriroys/spork-rails.git'
  gem 'spork-rails', github: 'railstutorial/spork-rails'
  gem 'factory_girl_rails'
end

