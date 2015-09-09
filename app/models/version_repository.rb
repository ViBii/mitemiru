class VersionRepository < ActiveRecord::Base
  has_many :projects
  has_many :commit_infos
  has_many :developers, through: :commit_infos
end
