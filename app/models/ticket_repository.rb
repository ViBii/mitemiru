class TicketRepository < ActiveRecord::Base
  has_many :redmine_keys
  has_many :projects
end
