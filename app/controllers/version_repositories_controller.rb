class VersionRepositoriesController < ApplicationController
  before_action :set_version_repository, only: [:show, :edit, :update, :destroy]
  def index
    @version_repositories = VersionRepository.all
  end

  def edit
  end

  def show
  end

  def destroy
    @version_repository.destroy
    respond_to do |format|
      format.html { redirect_to version_repositories_url, notice: 'version_repository was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_version_repository
    @version_repository = VersionRepository.find(params[:id])
  end

end
