class VersionRepository < ActiveRecord::Base
  has_many :projects
end
