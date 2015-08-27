class VersionRepository < ActiveRecord::Base
  has_many :projects
  mount_uploader :path, PathUploader
end
