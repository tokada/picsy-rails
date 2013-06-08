source 'http://rubygems.org'
ruby "2.0.0"

gem 'rails', '4.0.0.rc1'

# database
group :production do
  gem 'pg'
end
group :development, :test do
  gem 'sqlite3'
end

gem 'jquery-rails'

gem 'less-rails'
gem "font-awesome-rails"
group :assets do
	gem 'coffee-rails', '~> 4.0.0'
  gem 'therubyracer'
  gem 'uglifier', '>= 1.3.0'
end
gem 'twitter-bootswatch-rails'
gem 'twitter-bootswatch-rails-helpers'

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
  gem 'spork-rails', github: 'railstutorial/spork-rails'
  gem 'factory_girl_rails'
end

