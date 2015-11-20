class VersionRepository < ActiveRecord::Base
  has_many :github_keys
  has_many :projects
end
