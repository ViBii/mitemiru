class RedmineKeysController < ApplicationController
  # GET /redmine_keys/new
  def new
    @redmine_key = RedmineKey.new
  end

  # POST /redmine_keys/new
  def create
    @redmine_key = RedmineKey.new(redmine_key_params)
    #respond_to do |format|
      #format.html { render :new }
    #end
  end

  def redmine_key_params
    params.require(:redmine_keys).permit(
      :url,
      :login_name,
      :password_digest,
      :api_key
    )
  end
end
