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

group :assets do
  gem 'sass-rails', :git => 'git://github.com/rails/sass-rails.git'
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '~> 4.0.0'
end
gem 'bootstrap-sass'
gem 'bootswatch-rails'
gem 'jquery-rails'
gem "font-awesome-rails"

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

gem 'rest_in_place' # AJAX Inplace Editor

group :development do
  gem 'rails-erd'
end

group :test do
  gem 'rspec-rails'
  gem 'spork-rails', github: 'railstutorial/spork-rails'
  gem 'factory_girl_rails'
end

#group :production do
  gem 'rails_log_stdout',           github: 'heroku/rails_log_stdout'
  gem 'rails3_serve_static_assets', github: 'heroku/rails3_serve_static_assets'
#end

