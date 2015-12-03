class Developer < ActiveRecord::Base
  has_many :assign_logs, :dependent => :destroy
  has_many :projects, through: :assign_logs
end
