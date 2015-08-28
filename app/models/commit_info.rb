class CommitInfo < ActiveRecord::Base
  belongs_to :version_repository
  belongs_to :developer
end
