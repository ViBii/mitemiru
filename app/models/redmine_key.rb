class RedmineKey < ActiveRecord::Base
  belongs_to :ticket_repository
  belongs_to :user
end
