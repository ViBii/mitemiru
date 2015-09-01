source 'https://rubygems.org'

# Rails
gem 'rails', '4.2.3'
# DB
group :production do
  # heroku
  gem 'pg'
  gem 'rails_12factor'
  # gem 'mysql2'
end
group :development, :test do
  gem 'mysql2'
end
# SCSS
gem 'sass-rails', '~> 5.0'
# Uglifier
gem 'uglifier', '>= 1.3.0'
# CoffeeScript
gem 'coffee-rails', '~> 4.1.0'
# jquery
gem 'jquery-rails'
# Turbolinks
gem 'turbolinks'
# JSON APIs
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Bootstrap
gem 'bootstrap-sass', '~> 3.2.0'
gem 'autoprefixer-rails'
gem 'bootstrap-generators'

# HighCharts
gem 'lazy_high_charts'

# Password
gem 'bcrypt-ruby', '3.1.2'

# Rest-client
gem 'rest-client'

# secret
gem 'dotenv-rails'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

group :development, :test do
  # ER_Chart
  # brew install graphviz
  # http://qiita.com/satton_maroyaka/items/55e6cf42bd677c94d0d5
  gem 'rails-erd'

  gem 'teaspoon'
  gem 'selenium-webdriver'
  gem 'blanket-rails'
  gem 'phantomjs'
  gem "rspec"
  gem "rspec-rails"
  gem 'simplecov'
  gem 'simplecov-rcov'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'pry-rails'              # railsでpryが使える
  gem 'pry-byebug'             # pryでデバックコマンドが使える
  gem 'better_errors'          # エラー画面を見やすくする
  gem 'binding_of_caller'
  gem 'byebug'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'execjs'
  gem 'therubyracer'
end
