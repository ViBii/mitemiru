class Developer < ActiveRecord::Base
  has_many :assign_logs
  has_many :projects, through: :assign_logs
end
