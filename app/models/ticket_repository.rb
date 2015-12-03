class TicketRepository < ActiveRecord::Base
  has_many :redmine_keys, :dependent => :destroy
  has_many :projects
end
