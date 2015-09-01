class RedmineKeysController < ApplicationController
  before_action :set_redmine_key, only: [:show, :edit, :update, :destroy]
  
  def index
    @redmine_key = RedmineKey.all
  end

  # GET /redmine_keys/new
  def new
    @redmine_key = RedmineKey.new
  end

  # POST /redmine_keys/new
  def create
    @redmine_key = RedmineKey.new(redmine_key_params)

    if @redmine_key.save
      redirect_to '/redmine_keys/', notice: 'Successfully registered.'
    else
      format.html { redirect_to '/redmine_keys/new', status: 'Failed to register.' }
    end
  end

  def destroy
    @redmine_key.destroy
    respond_to do |format|
      format.html { redirect_to redmine_keys_url, notice: 'Developer was successfully destroyed.' }
    end
  end

  def set_redmine_key
    @redmine_key = RedmineKey.find(params[:id])
  end

  def redmine_key_params
    params.require(:redmine_key).permit(
      :ticket_repository_id,
      :login_name,
      :password_digest,
      :api_key
    )
  end
end
