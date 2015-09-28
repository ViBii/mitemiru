class TicketRepository < ActiveRecord::Base
  has_many :redmine_keys
  has_many :projects

  validates_numericality_of :url

end
