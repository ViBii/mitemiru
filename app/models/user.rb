class User < ActiveRecord::Base
  has_many :redmine_keys
  has_many :ticket_repositories, through: :redmine_keys
end
