class VersionRepositoriesController < ApplicationController
  def index
    @version_repositories = VersionRepository.all
  end
end
