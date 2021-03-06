require 'kconv'
require 'rest-client'
require 'json'

class DevelopersController < ApplicationController
  before_action :set_developer, only: [:show, :edit, :update, :destroy]

  # GET /developers
  # GET /developers.json
  def index
    developers = []
    Developer.all.each do |developer|
      developers << developer if ApplicationController.helpers.show_developer?(current_user, developer)
    end
    @developers = Kaminari.paginate_array(developers).page(params[:page]).per(PER)
  end

  # GET /developers/1
  # GET /developers/1.json
  def show
  end

  # GET /developers/new
  def new
    @developer = Developer.new
    @authorized_key = Hash.new
    @authorized_key[:url] = TicketRepository.find(params[:get_id][:ticket_repository_id])[:url]
    @authorized_key[:login_id] = RedmineKey.find_by(ticket_repository_id: params[:get_id][:ticket_repository_id])[:login_id]
    @authorized_key[:password_digest] = RedmineKey.find_by(ticket_repository_id: params[:get_id][:ticket_repository_id])[:password_digest]
    @authorized_key[:api_key] = RedmineKey.find_by(ticket_repository_id: params[:get_id][:ticket_repository_id])[:api_key]

    # get user data
    req = RestClient::Request.execute method: :get, url: @authorized_key[:url]+'/users.json', user: @authorized_key[:login_id], password: @authorized_key[:password_digest]

    # perse
    hash = JSON.parse(req)

    #
    @developer_info = Hash.new
    @developer_info[:total_count] = hash['total_count']
    @developer_info[:developers] = hash['users']

    @developer_info[:name] = Array.new
    for name in hash['users'] do
      @developer_info[:name].push(name['lastname']+' '+name['firstname'])
    end

    #render :text => @developer_info[:name]
  end

  # GET /developers/auth
  def auth
    @authorized_key = TicketRepository.joins(:redmine_keys).uniq
  end

  # GET /developers/1/edit
  def edit
  end

  # POST /developers
  # POST /developers.json
  def create
    @developer = Developer.new(developer_params)

    respond_to do |format|
      if @developer.save
        format.html { redirect_to @developer, notice: 'Developer was successfully created.' }
        format.json { render :show, status: :created, location: @developer }
      else
        format.html { render :new }
        format.json { render json: @developer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /developers/1
  # PATCH/PUT /developers/1.json
  def update
    respond_to do |format|
      if @developer.update(developer_params)
        format.html { redirect_to @developer, notice: '開発者情報を変更しました' }
        format.json { render :show, status: :ok, location: @developer }
      else
        format.html { render :edit }
        format.json { render json: @developer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /developers/1
  # DELETE /developers/1.json
  def destroy
    @developer.destroy
    respond_to do |format|
      format.html { redirect_to developers_url, notice: '開発者情報を削除しました' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_developer
    @developer = Developer.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def developer_params
    params.require(:developer).permit(
      :name,
      :email
    )
  end
end
