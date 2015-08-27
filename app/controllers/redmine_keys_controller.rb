class RedmineKeysController < ApplicationController
  # GET /redmine_keys/new
  def new
    @redmine_key = RedmineKey.new
  end

  # POST /redmine_keys/new
  def create
    #@redmine_key = RedmineKey.new(redmine_key_params)
    @redmine_key = RedmineKey.new
    #@redmine_key.ticket_repositoty_id = 0;
    #@redmine_key.user_id = 0;
    @redmine_key.api_key = params[:redmine_key][:api_key];
    @redmine_key.url = params[:redmine_key][:url];
    @redmine_key.login_name = params[:redmine_key][:login_name];
    @redmine_key.password_digest = params[:redmine_key][:password_digest];
    #respond_to do |format|
      #format.html { redirect_to @redmine_key, notice: 'Successfully registered.' }
    #end

    if @redmine_key.save
      redirect_to '/redmine_keys/new', notice: 'Sccessfully registered.'
    end
  end

#=begin
  def redmine_key_params
    params.require(:redmine_keys).permit(
      #:ticket_repositoty_id,
      #:user_id,
      :api_key,
      :url,
      :login_name,
      :password_digest,
    )
  end
#=end
end
