class RedmineKey < ActiveRecord::Base
  belongs_to :ticket_repository
  has_and_belongs_to_many :users
end
