gem install rails
rails new help_desk_backend --api --skip-kamal --skip-thruster  --database=mysql
cd help_desk_backend
gem "rack-cors" # For handling Cross-Origin Resource Sharing (CORS) requests from the frontend
gem "rack-cors"
gem "rack-cors"
gem "jwt"
gem "bcrypt"
gem "activerecord-session_store"
group :test do
  gem "mocha"
end
vim Gemfile
vim Gemfile
vim test/test_helper.rb
bundle install
rails db:create
rails db:migrate:status
rails db:create
rails server -b 0.0.0.0 -p 3000
exit
rails generate active_record:session_migration
cd help_desk_backend
rails generate active_record:session_migration
rails db:migrate
exit
cd help_desk_backend
rails server -b 0.0.0.0 -p 3000
exit
