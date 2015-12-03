class VersionRepository < ActiveRecord::Base
  has_many :github_keys, :dependent => :destroy
  has_many :projects
end
