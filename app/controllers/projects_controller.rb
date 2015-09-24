class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all
  end

  def select_developer
    if request.xhr?
      project_req = RestClient::Request.execute method: :get,
        url:      params['url'] + '/projects.json',
        user:     params['login_name'],
        password: params['password_digest']
      redmine_projects = JSON.parse(project_req)
      total_count = redmine_projects['total_count']
      projects = redmine_projects['projects']

      developer_req = RestClient::Request.execute method: :get,
        url:      params['url'] + '/users.json',
        user:     params['login_name'],
        password: params['password_digest']
      redmine_developers = JSON.parse(developer_req)
      @developers = redmine_developers['users']
      render :partial => "./layouts/developer_checkbox"
    end
  end

  def new
  end

  def create
    @project = Project.new(
      :name => params[:project][:name],
      :version_repository_id => VersionRepository.last.present? ? VersionRepository.last.id + 1 : 1,
      :ticket_repository_id  => TicketRepository.last.present?  ? TicketRepository.last.id  + 1 : 1
      #:project_start_date,
      #:project_end_date,
    )
    import_info = CommitInfo.import(params[:project][:file])

    respond_to do |format|
      if import_info && @project.save
        format.html { redirect_to projects_path, notice: 'プロジェクトが作成されました!' }
      else
        format.html { redirect_to projects_path, notice: 'ファイルの読み込みに失敗しました。' }
      end
    end
  end

  # GET /projects/auth
  def auth
    @authorized_key = TicketRepository.joins(:redmine_keys).uniq
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

  # POST /projects
  # POST /projects.json
  def auth_create
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


  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json

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

    def project_params
      params.require(:project).permit(
        :name,
        :version_repository_id,
        :ticket_repository_id,
        :file,
        :project_start_date,
        :project_end_date,
      )
    end

    def version_repository_params
      params.require(:version_repository).permit(
        :commit_volume
      )
    end
end
