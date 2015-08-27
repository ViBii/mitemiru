class RedmineKeysController < ApplicationController
  # GET /redmine_keys/new
  def new
    @redmine_key = RedmineKey.new
  end

  # POST /redmine_keys/new
  def create
    #@redmine_key = RedmineKey.new(redmine_key_params)
    @redmine_key = RedmineKey.new
    @redmine_key.id = 0;
    @redmine_key.ticket_repositoty_id = 0;
    @redmine_key.user_id = 0;
    @redmine_key.api_key = params[:api_key];
    @redmine_key.url = params[:url];
    @redmine_key.login_name = params[:login_name];
    @redmine_key.password_digest = params[:password_digest];
    @redmine_key.created_at = params[:create_at];
    @redmine_key.updated_at = params[:update_at];
    #respond_to do |format|
      #format.html { render :new }
    #end
    redirect_to '/base/top'    
  end

=begin
  def redmine_key_params
    params.require(:redmine_keys).permit(
      :id,
      :ticket_repository_id,
      :user_id,
      :api_key,
      :url,
      :login_name,
      :password_digest,
      :create_at,
      :update_at
    )
  end
=end
end
