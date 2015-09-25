class VersionRepositoriesController < ApplicationController
  def index
    @version_repositories = VersionRepository.all
  end

  def edit
  end

  def show
  end

end
