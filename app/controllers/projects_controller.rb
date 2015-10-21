class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    @projects = Project.all
  end

  def select_developer
    if request.xhr?
      @url             = params['url']
      @login_id        = params['login_id']
      @password_digest = params['password_digest']
      @api_key         = params['api_key']

      # Redmineの全プロジェクトを取得するスクリプト
      # project_req = RestClient::Request.execute method: :get,
      #   url:      params['url'] + '/projects.json',
      #   user:     params['login_id'],
      #   password: params['password_digest']
      # redmine_projects = JSON.parse(project_req)
      # total_count = redmine_projects['total_count']
      # projects = redmine_projects['projects']

      developer_req = RestClient::Request.execute method: :get,
        url:      params['url'] + '/users.json',
        user:     params['login_id'],
        password: params['password_digest']
      redmine_developers = JSON.parse(developer_req)
      developers = redmine_developers['users']

      # Save
      # ticket_repositories
      ticket_repository = TicketRepository.new(
        :url => params['url']
      )
      ticket_repository.save unless TicketRepository.exists?(url: params['url'])

      # redmine_keys
      if TicketRepository.where(url: params['url']).select(:id).present?
        ticket_repository_id = TicketRepository.where(url: params['url']).pluck(:id).first
      else
        ticket_repository_id = TicketRepository.last.present? ? TicketRepository.last.id + 1 : 1
      end
      unless RedmineKey.exists?(ticket_repository_id: ticket_repository_id, login_id: params['login_id'])
        redmine_key = RedmineKey.new(
          :ticket_repository_id => ticket_repository_id,
          :login_id             => params['login_id'],
          :password_digest      => params['password_digest'],
          :api_key              => params['api_key']
        )
        redmine_key.save
      end
      session[:ticket_repository_id] = ticket_repository_id

      render :partial => "developer_checkbox", :locals => { developers: developers }
    end
  end

  def auth_github
    @url             = params['url']
    @login_id        = params['login_id']
    @password_digest = params['password_digest']
    @api_key         = params['api_key']
    session[:developers_id] = params[:developer][:id]
    @scope_projects = []

    params[:developer][:id].each do |developer_id|
      project_req = RestClient::Request.execute method: :get,
        url:      params['url'] + "/users/#{developer_id}.json?include=memberships,groups",
        user:     params['login_id'],
        password: params['password_digest']
      redmine_projects = JSON.parse(project_req)

      redmine_projects["user"]["memberships"].each do |project|
        @scope_projects << project["project"]["name"]
      end
    end
    @scope_projects.uniq!
  end

  def confirm
    @confirm_data = {
      name:                    params['name'],
      start_date:              params['start_date'],
      redmine_url:             params['redmine_url'],
      redmine_login_id:        params['redmine_login_id'],
      redmine_password_digest: params['redmine_password_digest'],
      redmine_api_key:         params['redmine_api_key'],
      github_url:              params['github_url'],
      github_login_id:         params['github_login_id'],
      github_password_digest:  params['github_password_digest']
    }
  end

  def create
    begin
      # Save
      developer_info = Hash.new { |h,k| h[k] = {} }

      session[:developers_id].each do |developer_id|
        project_req = RestClient::Request.execute method: :get,
          url:      params['url'] + "/users/#{developer_id}.json?include=memberships,groups",
          user:     params['login_id'],
          password: params['password_digest']
        redmine_projects = JSON.parse(project_req)

        # RedmineのloginIDを開発者の名前とする
        developer_info[redmine_projects['user']['login']][:email] = redmine_projects["user"]["mail"]
        developer_info[redmine_projects['user']['login']][:project] = []

        redmine_projects["user"]["memberships"].each do |project|
          developer_info[redmine_projects['user']['login']][:project] << project["project"]["name"]
        end
      end

      # version_repositories, github_keys, projects
      params["github_info"].each do |github_info|
        version_repository = VersionRepository.new(
          :url => github_info['url']
        )
        version_repository.save unless VersionRepository.exists?(url: github_info['url'])

        if VersionRepository.where(url: github_info['url']).select(:id).present?
          version_repository_id = VersionRepository.where(url: github_info['url']).pluck(:id).first
        else
          version_repository_id = VersionRepository.last.present? ? VersionRepository.last.id + 1 : 1
        end
        unless GithubKey.exists?(version_repository_id: version_repository_id, login_id: github_info['login_id'])
          github_key = GithubKey.new(
            :version_repository_id => version_repository_id,
            :login_id              => github_info['login_id'],
            :password_digest       => github_info['password_digest'],
          )
          github_key.save
        end

        if Project.where(name: github_info["name"]).present?
          same_project = Project.where(name: github_info["name"]).first
          same_project.update(
            :id                    => same_project.id,
            :version_repository_id => version_repository_id,
            :ticket_repository_id  => session["ticket_repository_id"],
            :name                  => github_info["name"],
            :project_start_date    => nil,
            :project_end_date      => nil
          )
        else
          project = Project.new(
            :version_repository_id => version_repository_id,
            :ticket_repository_id  => session["ticket_repository_id"],
            :name                  => github_info["name"],
            :project_start_date    => nil,
            :project_end_date      => nil
          )
          project.save
        end
      end

      # developers, assign_logs
      developer_info.each do |developer_info|
        developer = Developer.new(
          :name  => developer_info.first,
          :email => developer_info.second[:email]
        )
        developer.save unless Developer.exists?(email: developer_info.second[:email])

        developer_id = Developer.where(email: developer_info.second[:email]).pluck(:id).first
        developer_info.second[:project].each do |project_name|
          project_id = Project.where(name: project_name).pluck(:id).first
          unless AssignLog.exists?(developer_id: developer_id, project_id: project_id)
            assign_log = AssignLog.new(
              :developer_id      => developer_id,
              :project_id        => project_id,
              :assign_start_date => nil,
              :assign_end_date   => nil
            )
            assign_log.save
          end
        end
      end
      session[:ticket_repository_id] = nil
      session[:developers_id]        = nil

      respond_to do |format|
        format.html { redirect_to projects_path, notice: 'プロジェクトが作成されました!' }
      end
    rescue
      respond_to do |format|
        format.html { redirect_to projects_path, notice: 'プロジェクト作成に失敗しました...' }
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
        :project_start_date,
        :project_end_date,
      )
    end
end
