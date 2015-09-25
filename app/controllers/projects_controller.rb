class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all
  end

  def select_developer
    if request.xhr?
      @url             = params['url']
      @login_name      = params['login_name']
      @password_digest = params['password_digest']
      @api_key         = params['api_key']

      # Redmineの全プロジェクトを取得するスクリプト
      # project_req = RestClient::Request.execute method: :get,
      #   url:      params['url'] + '/projects.json',
      #   user:     params['login_name'],
      #   password: params['password_digest']
      # redmine_projects = JSON.parse(project_req)
      # total_count = redmine_projects['total_count']
      # projects = redmine_projects['projects']

      developer_req = RestClient::Request.execute method: :get,
        url:      params['url'] + '/users.json',
        user:     params['login_name'],
        password: params['password_digest']
      redmine_developers = JSON.parse(developer_req)
      developers = redmine_developers['users']
      render :partial => "developer_checkbox", :locals => { developers: developers }
    end
  end

  def auth_github
    url             = params['url']
    login_name      = params['login_name']
    password_digest = params['password_digest']
    api_key         = params['api_key']
    scope_projects  = []

    params[:developer][:id].each do |developer_id|
      project_req = RestClient::Request.execute method: :get,
        url:      params['url'] + "/users/#{developer_id}.json?include=memberships,groups",
        user:     params['login_name'],
        password: params['password_digest']
      redmine_projects = JSON.parse(project_req)
      redmine_projects["user"]["memberships"].each do |project|
        scope_projects << project["project"]["name"]
      end
    end
    @scope_projects = scope_projects.uniq
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

  def edit
  end

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
