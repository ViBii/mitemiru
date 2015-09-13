class GithubKey < ActiveRecord::Base
  belongs_to :version_repository
  #has_and_belongs_to_many :users
end
