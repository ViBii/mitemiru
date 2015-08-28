class RedmineKeysController < ApplicationController
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
      redirect_to '/redmine_keys/new', notice: 'Successfully registered.'
    else
      redirect_to '/redmine_keys/new', status: 'Failed to register.'
    end
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
