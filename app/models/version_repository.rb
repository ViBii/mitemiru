class VersionRepository < ActiveRecord::Base
  mount_uploader :path, PathUploader
  has_many :projects
end
