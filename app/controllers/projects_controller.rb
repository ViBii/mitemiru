class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
  end

  # GET /projects/auth_new
  def auth_new
    @project = Project.new
    @authorized_key = Hash.new
    @authorized_key[:url] = TicketRepository.find(params[:get_id][:ticket_repository_id])[:url]
    @authorized_key[:ticket_repository_id] = RedmineKey.find_by(ticket_repository_id: params[:get_id][:ticket_repository_id])[:ticket_repository_id]
    @authorized_key[:login_name] = RedmineKey.find_by(ticket_repository_id: params[:get_id][:ticket_repository_id])[:login_name]
    @authorized_key[:password_digest] = RedmineKey.find_by(ticket_repository_id: params[:get_id][:ticket_repository_id])[:password_digest]
    @authorized_key[:api_key] = RedmineKey.find_by(ticket_repository_id: params[:get_id][:ticket_repository_id])[:api_key]

    # get user data
    req = RestClient::Request.execute method: :get, url: @authorized_key[:url]+'/projects.json', user: @authorized_key[:login_name], password: @authorized_key[:password_digest]

    # parse
    hash = JSON.parse(req)

    #
    @project_info = Hash.new
    @project_info[:total_count] = hash['total_count']
    @project_info[:projects] = hash['projects']

    @project_info[:name] = Array.new
    for name in hash['projects'] do
      @project_info[:name].push(name['name'])
    end

    #render :text => @developer_info[:name]
  end

  # GET /projects/auth
  def auth
    @authorized_key = TicketRepository.joins(:redmine_keys).uniq
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(
        :name,
        :ticket_repository_id
      )
    end
end
