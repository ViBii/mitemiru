class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    @projects = Project.all
  end

  def new
    @today = Time.now.strftime("%Y/%m/%d ")
  end

  def confirm
    @confirm_data = {
      name:                    params['name'],
      project_start_date:      params['project_start_date'],
      redmine_host:            params['redmine_host'],
      redmine_project_name:    params['redmine_project_name'],
      redmine_login_id:        params['redmine_login_id'],
      redmine_password_digest: params['redmine_password_digest'],
      redmine_api_key:         params['redmine_api_key'],
      github_project_name:     params['github_project_name'],
      github_repo:             params['github_repo'],
      github_login_id:         params['github_login_id'],
      github_password_digest:  params['github_password_digest']
    }

    # Redmineホスト名の整形
    if @confirm_data[:redmine_host].match(/https:\/\//)
      @confirm_data[:redmine_host].slice!(/https:\/\//)
    elsif @confirm_data[:redmine_host].match(/http:\/\//)
      @confirm_data[:redmine_host].slice!(/http:\/\//)
    end

    # Validate
    if params['redmine_host'].present?
      begin
        req = RestClient::Request.execute method: :get,
          url:      'https://' + params['redmine_host'] + '/projects/' + params['redmine_project_name'] + '/memberships.json',
          user:     params['redmine_login_id'],
          password: params['redmine_password_digest']
      rescue
        @confirm_data[:redmine_host] = UNAUTH
        @confirm_data[:redmine_project_name] = UNAUTH
      end
    else
      @confirm_data[:redmine_host] = UNAUTH
      @confirm_data[:redmine_project_name] = UNAUTH
    end

    if params['github_project_name'].present?
      begin
        req = RestClient::Request.execute method: :get,
          url:      'https://api.github.com/orgs/' + params['github_project_name'] + '/members',
          user:     params['github_login_id'],
          password: params['github_password_digest']
      rescue
        @confirm_data[:github_project_name] = UNAUTH
        @confirm_data[:github_repo] = UNAUTH
      end
    else
      @confirm_data[:github_project_name] = UNAUTH
      @confirm_data[:github_repo] = UNAUTH
    end

    validate_text = ""
    if @confirm_data[:name].blank? || @confirm_data[:project_start_date].blank?
      validate_text += VALIDATE_PROJECT_NAME + "　"
    end
    if @confirm_data[:redmine_project_name] == UNAUTH && @confirm_data[:github_project_name] == UNAUTH
      validate_text += VALIDATE_REDMINE_GITHUB_AUTH
    end

    if validate_text.present?
      respond_to do |format|
        format.html { redirect_to new_project_path, notice: validate_text }
      end
    end
  end

  def create
    # 以下の順序で登録
    # ticket_repositories
    # redmine_keys
    # redmine_authorities
    # version_repositories
    # github_keys
    # github_authorities
    # projects
    # developers
    # assign_logs

    begin
      data = {
        name:                    params['name'],
        project_start_date:      params['project_start_date'],
        redmine_host:            params['redmine_host'],
        redmine_project_name:    params['redmine_project_name'],
        redmine_login_id:        params['redmine_login_id'],
        redmine_password_digest: params['redmine_password_digest'],
        redmine_api_key:         params['redmine_api_key'],
        github_project_name:     params['github_project_name'],
        github_repo:             params['github_repo'],
        github_login_id:         params['github_login_id'],
        github_password_digest:  params['github_password_digest']
      }

      redmine_url = data[:redmine_host] + '/projects/' + data[:redmine_project_name]
      github_url = 'github.com/' + data[:github_project_name] + '/' + data[:github_repo]

      if TicketRepository.where(url: redmine_url).select(:id).present?
        ticket_repository_id = TicketRepository.where(url: redmine_url).pluck(:id).first
      else
        ticket_repository_id = TicketRepository.last.present? ? TicketRepository.last.id + 1 : 1
      end
      if VersionRepository.where(url: github_url).select(:id).present?
        version_repository_id = VersionRepository.where(url: github_url).pluck(:id).first
      else
        version_repository_id = VersionRepository.last.present? ? VersionRepository.last.id + 1 : 1
      end

      if data[:redmine_project_name] != UNAUTH
        # ticket_repositories
        unless TicketRepository.exists?(url: redmine_url)
          ticket_repository = TicketRepository.new(
            url: redmine_url
          )
          ticket_repository.save
        end

        # redmine_keys
        unless RedmineKey.exists?(ticket_repository_id: ticket_repository_id, login_id: data[:redmine_login_id])
          redmine_key = RedmineKey.new(
            :ticket_repository_id => ticket_repository_id,
            :login_id             => data[:redmine_login_id],
            :password_digest      => data[:redmine_password_digest],
            :api_key              => data[:redmine_api_key]
          )
          redmine_key.save
        end

        # redmine_authorities
        unless current_user.redmine_keys.present?
          current_user.redmine_keys << RedmineKey.where(ticket_repository_id: ticket_repository_id, login_id: data[:redmine_login_id])
        end
      end

      if data[:github_project_name] != UNAUTH

        # version_repositories
        unless VersionRepository.exists?(url: github_url)
          version_repository = VersionRepository.new(
            url: github_url
          )
          version_repository.save
        end

        # github_keys
        unless GithubKey.exists?(version_repository_id: version_repository_id, login_id: data[:github_login_id])
          github_key = GithubKey.new(
            :version_repository_id => version_repository_id,
            :login_id             => data[:github_login_id],
            :password_digest      => data[:github_password_digest]
          )
          github_key.save
        end

        # github_authorities
        unless current_user.github_keys.present?
          current_user.github_keys << GithubKey.where(version_repository_id: version_repository_id, login_id: data[:github_login_id])
        end
      end

      if data[:redmine_project_name] == UNAUTH
        ticket_repository_id = nil
      end
      if data[:github_project_name] == UNAUTH
        version_repository_id = nil
      end

      # projects
      if Project.where(name: data[:name]).present?
        same_project = Project.where(name: data[:name]).first
        same_project.update(
          :id                    => same_project.id,
          :version_repository_id => version_repository_id,
          :ticket_repository_id  => ticket_repository_id,
          :name                  => data[:name],
          :project_start_date    => Date.parse(data[:project_start_date])
        )
      else
        project = Project.new(
          :version_repository_id => version_repository_id,
          :ticket_repository_id  => ticket_repository_id,
          :name                  => data[:name],
          :project_start_date    => Date.parse(data[:project_start_date])
        )
        project.save
      end

      if data[:redmine_project_name] != UNAUTH
        # Redmineからユーザ情報を取得する場合

        # developers
        # assign_logs
        developer_list = RestClient::Request.execute method: :get,
          url:      data[:redmine_host] + '/projects/' + data[:redmine_project_name] + '/memberships.json',
          user:     data[:redmine_login_id],
          password: data[:redmine_password_digest]
        redmine_developers = JSON.parse(developer_list)
        developers = redmine_developers["memberships"]
        redmine_developer_id_list = []

        developers.each do |developer|
          redmine_developer_id_list << developer['user']['id']
        end
        redmine_developer_id_list.each do |redmine_developer_id|
          redmine_developer_info = RestClient::Request.execute method: :get,
            url:      'https://' + data[:redmine_host] + "/users/#{redmine_developer_id}.json?include=memberships,groups",
            user:     data[:redmine_login_id],
            password: data[:redmine_password_digest]
          redmine_developer_info = JSON.parse(redmine_developer_info)

          unless Developer.exists?(email: redmine_developer_info['user']['mail'])
            developer = Developer.new(
              :name  => redmine_developer_info['user']['login'],
              :email => redmine_developer_info['user']['mail']
            )
            developer.save
          end

          developer = Developer.where(email: redmine_developer_info['user']['mail']).first
          project = Project.where(name: data[:name]).first
          unless AssignLog.exists?(developer_id: developer.id, project_id: project.id)
            assign_log = AssignLog.new(
              :developer_id      => developer.id,
              :project_id        => project.id,
              :assign_start_date => nil,
              :assign_end_date   => nil
            )
            assign_log.save
          end
        end
      else
        # GitHubからユーザ情報を取得する場合

        # developers
        # assign_logs
        developer_list = RestClient::Request.execute method: :get,
          url:      'https://api.github.com/orgs/' + data[:github_project_name] + '/members',
          user:     data[:github_login_id],
          password: data[:github_password_digest]
        github_developers = JSON.parse(developer_list)
        github_developer_list = []

        github_developers.each do |github_developer|
          github_developer_list << github_developer['login']
        end
        github_developer_list.each do |github_developer|
          github_developer_info = RestClient::Request.execute method: :get,
            url: 'https://api.github.com/users/' + github_developer,
            user:     data[:github_login_id],
            password: data[:github_password_digest]
          github_developer_info = JSON.parse(github_developer_info)

          unless Developer.exists?(email: github_developer_info['email'])
            developer = Developer.new(
              :name  => github_developer_info['login'],
              :email => github_developer_info['email']
            )
            developer.save
          end

          developer = Developer.where(email: github_developer_info['email']).first
          project = Project.where(name: data[:name]).first
          unless AssignLog.exists?(developer_id: developer.id, project_id: project.id)
            assign_log = AssignLog.new(
              :developer_id      => developer.id,
              :project_id        => project.id,
              :assign_start_date => nil,
              :assign_end_date   => nil
            )
            assign_log.save
          end
        end
      end
      respond_to do |format|
        format.html { redirect_to projects_path, notice: 'プロジェクトが登録されました!' }
      end
    rescue
      respond_to do |format|
        format.html { redirect_to projects_path, notice: 'プロジェクト登録に失敗しました....' }
      end
    end
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

  def authen_git
    @project = Project.find(params[:project_id])
    @version_repository = VersionRepository.find_by(:id => @project.version_repository_id)
    @github_key = GithubKey.find_by(:version_repository_id =>@version_repository)
  end

  def authen_red
    @project = Project.find(params[:project_id])
    @ticket_repository = TicketRepository.find_by(:id => @project.ticket_repository_id)
    @redmine_key = RedmineKey.find_by(:ticket_repository_id =>@ticket_repository)
  end

  def add_git
    @project = Project.find(params[:project_id])
  end

  def add_red
    @project = Project.find(params[:project_id])
  end

  private

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
