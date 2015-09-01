class Developer < ActiveRecord::Base
  has_many :assign_logs
  has_many :projects, through: :assign_logs
  has_many :commit_infos
  has_many :version_repositories, through: :commit_infos
end
