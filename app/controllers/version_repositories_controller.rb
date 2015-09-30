class VersionRepositoriesController < ApplicationController
  before_action :set_version_repository, only: [:show, :edit, :update, :destroy]
  def index
    @version_repositories = VersionRepository.all
  end

  def edit
  end

  def show
  end

<<<<<<< HEAD
  def destroy
    @version_repository.destroy
    respond_to do |format|
      format.html { redirect_to version_repositories_url, notice: 'version_repository was successfully destroyed.' }
      format.json { head :no_content }
=======
  def update
    respond_to do |format|
      if @version_repository.update(version_repository_params)
        format.html { redirect_to @version_repository, notice: 'version_repository was successfully updated.' }
        format.json { render :show, status: :ok, location: @version_repository }
      else
        format.html { render :edit }
        format.json { render json: @version_repository.errors, status: :unprocessable_entity }
      end
>>>>>>> bugofsubmitbtn
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_version_repository
    @version_repository = VersionRepository.find(params[:id])
  end

  def version_repository_params
    params.require(:version_repository).permit(
        :url
    )
  end

end
