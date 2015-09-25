class VersionRepositoriesController < ApplicationController
  before_action :set_version_repository, only: [:show, :edit, :update, :destroy]
  def index
    @version_repositories = VersionRepository.all
  end

  def edit
  end

  def show
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_version_repository
    @version_repository = VersionRepository.find(params[:id])
  end

end
