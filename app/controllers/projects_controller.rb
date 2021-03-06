class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    projects = []
    Project.all.each do |project|
      projects << project if ApplicationController.helpers.show_project?(current_user, project)
    end
    @projects = Kaminari.paginate_array(projects).page(params[:page]).per(PER)
  end

  def new
    @today = Time.now.strftime("%Y/%m/%d ")
  end

  def confirm
    redmine_url         = params[:redmine_url]
    github_project_name = params[:github_project_name]
    github_repo         = params[:github_repo]

    cookies[:name] = params[:name]
    cookies[:redmine_url]  = params[:redmine_url]
    cookies[:redmine_login_id] = params[:redmine_login_id]
    cookies[:github_project_name] = params[:github_project_name]
    cookies[:github_repo]  = params[:github_repo]
    cookies[:github_login_id] = params[:github_login_id]

    # Validate
    if params['redmine_url'].present?
      begin
      # Redmineホスト名の整形
      if redmine_url.match(/https:\/\//)
        redmine_url.slice!(/https:\/\//)
      elsif redmine_url.match(/http:\/\//)
        redmine_url.slice!(/http:\/\//)
      end
      /\/projects\// =~ redmine_url
      redmine_host = $`
      redmine_project_name = $'
      if redmine_project_name.match(/\//)
        redmine_url.slice!(/\//)
      end

      req = RestClient::Request.execute method: :get,
        url:      redmine_host + '/users.xml?',
        user:     params['redmine_login_id'],
        password: params['redmine_password_digest']
      rescue
        redmine_host = UNAUTH
        redmine_project_name = UNAUTH
      end
    else
      redmine_host = UNAUTH
      redmine_project_name = UNAUTH
    end

    if params['github_project_name'].present? && params['github_repo'].present?
      begin
        req = RestClient::Request.execute method: :get,
          url:      'https://api.github.com/orgs/' + params['github_project_name'] + '/members',
          user:     params['github_login_id'],
          password: params['github_password_digest']
      rescue
        github_project_name = UNAUTH
        github_repo = UNAUTH
      end
    else
      github_project_name = UNAUTH
      github_repo = UNAUTH
    end

    validate_text = ""
    if params['name'].blank?
      validate_text += VALIDATE_PROJECT_NAME + "　"
    end
    if redmine_project_name == UNAUTH && github_project_name == UNAUTH
      validate_text += VALIDATE_REDMINE_GITHUB_AUTH
    end

    if validate_text.present?
      respond_to do |format|
        format.html { redirect_to new_project_path, notice: validate_text }
      end
    end

    @confirm_data = {
      name:                    params['name'],
      project_start_date:      params['project_start_date'],
      redmine_host:            redmine_host,
      redmine_project_name:    redmine_project_name,
      redmine_login_id:        params['redmine_login_id'],
      redmine_password_digest: params['redmine_password_digest'],
      github_project_name:     github_project_name,
      github_repo:             github_repo,
      github_login_id:         params['github_login_id'],
      github_password_digest:  params['github_password_digest']
    }

  end

  def create
    cookies.delete :name
    cookies.delete :redmine_url
    cookies.delete :redmine_login_id
    cookies.delete :github_project_name
    cookies.delete :github_repo
    cookies.delete :github_login_id
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

      if TicketRepository.where(host_name: data[:redmine_host], project_name: data[:redmine_project_name]).select(:id).present?
        ticket_repository_id = TicketRepository.where(
          host_name: data[:redmine_host],
          project_name: data[:redmine_project_name]).pluck(:id).first
      else
        ticket_repository_id = TicketRepository.last.present? ? TicketRepository.last.id + 1 : 1
      end
      if VersionRepository.where(repository_name: data[:github_repo], project_name: data[:github_project_name]).select(:id).present?
        version_repository_id = VersionRepository.where(
          repository_name: data[:github_repo],
          project_name: data[:github_project_name]).pluck(:id).first
      else
        version_repository_id = VersionRepository.last.present? ? VersionRepository.last.id + 1 : 1
      end

      if data[:redmine_project_name] != UNAUTH
        # ticket_repositories
        unless TicketRepository.exists?(host_name: data[:redmine_host], project_name: data[:redmine_project_name])
          ticket_repository = TicketRepository.new(
            host_name: data[:redmine_host],
            project_name: data[:redmine_project_name]
          )
          ticket_repository.save
          ticket_repository_id = TicketRepository.last.id
        end

        # redmine_keys
        if RedmineKey.exists?(ticket_repository_id: ticket_repository_id, login_id: data[:redmine_login_id]).blank?
          redmine_key = RedmineKey.new(
            :ticket_repository_id => ticket_repository_id,
            :login_id             => data[:redmine_login_id],
            :password_digest      => data[:redmine_password_digest],
            :api_key              => data[:redmine_api_key]
          )
          redmine_key.save

        # redmine_authorities
          current_user.redmine_keys << RedmineKey.where(ticket_repository_id: ticket_repository_id, login_id: data[:redmine_login_id])
        elsif current_user.redmine_keys.where(ticket_repository_id: ticket_repository_id, login_id: data[:redmine_login_id]).blank?
          current_user.redmine_keys << RedmineKey.where(ticket_repository_id: ticket_repository_id, login_id: data[:redmine_login_id])
        end
      end

      if data[:github_project_name] != UNAUTH
        # version_repositories
        unless VersionRepository.exists?(repository_name: data[:github_repo], project_name: data[:github_project_name])
          version_repository = VersionRepository.new(
            repository_name: data[:github_repo],
            project_name: data[:github_project_name]
          )
          version_repository.save
          version_repository_id = VersionRepository.last.id
        end

        # github_keys
        if GithubKey.where(version_repository_id: version_repository_id, login_id: data[:github_login_id]).blank?
          github_key = GithubKey.new(
            :version_repository_id => version_repository_id,
            :login_id             => data[:github_login_id],
            :password_digest      => data[:github_password_digest]
          )
          github_key.save

        # github_authorities
          current_user.github_keys << GithubKey.where(version_repository_id: version_repository_id, login_id: data[:github_login_id])
        elsif current_user.github_keys.where(version_repository_id: version_repository_id, login_id: data[:github_login_id]).blank?
          current_user.github_keys << GithubKey.where(version_repository_id: version_repository_id, login_id: data[:github_login_id])
        end
      end

      if data[:redmine_project_name] == UNAUTH
        ticket_repository_id  = nil
        ticket_repository_id = Project.where(name: data[:name]).first.ticket_repository_id if Project.exists?(name: data[:name])
      end
      if data[:github_project_name] == UNAUTH
        version_repository_id = nil
        version_repository_id = Project.where(name: data[:name]).first.version_repository_id if Project.exists?(name: data[:name])
      end

      # projects
      if Project.where(name: data[:name], user_id: current_user.id).present?
        same_project = Project.where(name: data[:name], user_id: current_user.id).first
        same_project.update(
          :id                    => same_project.id,
          :version_repository_id => version_repository_id,
          :ticket_repository_id  => ticket_repository_id,
          :name                  => data[:name],
          # :project_start_date    => Date.parse(data[:project_start_date]),
          :user_id               => current_user.id
        )
      else
        project = Project.new(
          :version_repository_id => version_repository_id,
          :ticket_repository_id  => ticket_repository_id,
          :name                  => data[:name],
          # :project_start_date    => Date.parse(data[:project_start_date]),
          :user_id               => current_user.id
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
            url:      data[:redmine_host] + "/users/#{redmine_developer_id}.json?include=memberships,groups",
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

  def new_redmine
    @project = Project.find(params[:project_id])
  end

  def new_github
    @project = Project.find(params[:project_id])
  end

  def edit_redmine
    @project = Project.find(params[:project_id])
    @ticket_repository = TicketRepository.find_by(:id => @project.ticket_repository_id)
    user_redmine_keys = current_user.redmine_keys
    @redmine_key = user_redmine_keys.find_by(:ticket_repository_id => @ticket_repository)
  end

  def edit_github
    @project = Project.find(params[:project_id])
    @version_repository = VersionRepository.find_by(:id => @project.version_repository_id)
    user_github_keys = current_user.github_keys
    @github_key = user_github_keys.find_by(:version_repository_id => @version_repository)
  end

  def auth_redmine
    data = {
      name:                    params['name'],
      redmine_url:             params['redmine_url'],
      redmine_login_id:        params['redmine_login_id'],
      redmine_password_digest: params['redmine_password_digest']
    }

    # Validate
    if data[:redmine_url].present?
      begin
      # Redmineホスト名の整形
      if data[:redmine_url].match(/https:\/\//)
        data[:redmine_url].slice!(/https:\/\//)
      elsif data[:redmine_url].match(/http:\/\//)
        data[:redmine_url].slice!(/http:\/\//)
      end
      /\/projects\// =~ data[:redmine_url]
      redmine_host = $`
      redmine_project_name = $'
      if redmine_project_name.match(/\//)
        redmine_url.slice!(/\//)
      end

      req = RestClient::Request.execute method: :get,
        url:      redmine_host + '/users.xml?',
        user:     params['redmine_login_id'],
        password: params['redmine_password_digest']
      rescue
        redmine_host = UNAUTH
        redmine_project_name = UNAUTH
      end
    else
      redmine_host = UNAUTH
      redmine_project_name = UNAUTH
    end

    if redmine_project_name != UNAUTH
      # ticket_repositories
      unless TicketRepository.exists?(host_name: redmine_host, project_name: redmine_project_name)
        ticket_repository = TicketRepository.new(
          host_name: redmine_host,
          project_name: redmine_project_name
        )
        ticket_repository.save
      end

      # redmine_keys
      if TicketRepository.where(host_name: redmine_host, project_name: redmine_project_name).select(:id).present?
        ticket_repository_id = TicketRepository.where(
          host_name: redmine_host,
          project_name: redmine_project_name).pluck(:id).first
      else
        ticket_repository_id = TicketRepository.last.present? ? TicketRepository.last.id + 1 : 1
      end
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
      unless RedmineKey.exists?(ticket_repository_id: ticket_repository_id, login_id: data[:redmine_login_id])
        current_user.redmine_keys << RedmineKey.where(ticket_repository_id: ticket_repository_id, login_id: data[:redmine_login_id])
      end

      same_project = Project.where(name: data[:name]).first
      same_project.update(
          :id                    => same_project.id,
          :ticket_repository_id => ticket_repository_id,
      )

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
          url:      data[:redmine_host] + "/users/#{redmine_developer_id}.json?include=memberships,groups",
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
      respond_to do |format|
        format.html { redirect_to projects_path, notice: UPDATE_PROJECT_MESSAGE }
      end
    else
      respond_to do |format|
        format.html { redirect_to projects_path, notice: UPDATE_PROJECT_ERROR_MESSAGE }
      end
    end
  end

  def auth_github
    data = {
      name:                    params['name'],
      github_project_name:     params['github_project_name'],
      github_repo:             params['github_repo'],
      github_login_id:         params['github_login_id'],
      github_password_digest:  params['github_password_digest']
    }

    if data[:github_project_name].present? && data[:github_repo].present?
      begin
        req = RestClient::Request.execute method: :get,
          url:      'https://api.github.com/orgs/' + data[:github_project_name] + '/members',
          user:     data[:github_login_id],
          password: data[:github_password_digest]
      rescue
        data[:github_project_name] = UNAUTH
        data[:github_repo] = UNAUTH
      end
    else
      data[:github_project_name] = UNAUTH
      data[:github_repo] = UNAUTH
    end

    if data[:github_project_name] != UNAUTH
      # version_repositories
      unless VersionRepository.exists?(project_name: data[:github_project_name], repository_name: data[:github_repo])
        version_repository = VersionRepository.new(
          project_name: data[:github_project_name],
          repository_name: data[:github_repo]
        )
        version_repository.save
      end

      # github_keys
      if VersionRepository.where(project_name: data[:github_project_name], repository_name: data[:github_repo]).select(:id).present?
        version_repository_id = VersionRepository.where(
          project_name: data[:github_project_name],
          repository_name: data[:github_repo]).pluck(:id).first
      else
        version_repository_id = VersionRepository.last.present? ? VersionRepository.last.id + 1 : 1
      end
      unless GithubKey.exists?(version_repository_id: version_repository_id, login_id: data[:github_login_id])
        github_key = GithubKey.new(
            :version_repository_id => version_repository_id,
            :login_id             => data[:github_login_id],
            :password_digest      => data[:github_password_digest]
        )
        github_key.save
      end

      # github_authorities
      unless GithubKey.exists?(version_repository_id: version_repository_id, login_id: data[:github_login_id])
        current_user.github_keys << GithubKey.where(version_repository_id: version_repository_id, login_id: data[:github_login_id])
      end

      same_project = Project.where(name: data[:name]).first
      same_project.update(
          :id                    => same_project.id,
          :version_repository_id => version_repository_id,
      )

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
      respond_to do |format|
        format.html { redirect_to projects_path, notice: UPDATE_PROJECT_MESSAGE }
      end
    else
      respond_to do |format|
        format.html { redirect_to projects_path, notice: UPDATE_PROJECT_ERROR_MESSAGE }
      end
    end
  end

  def unauth
    project = Project.find_by(id: params[:project_id])
    action = Rails.application.routes.recognize_path(request.referrer)[:action]
    if action == "edit_redmine"
      project.update(
          :ticket_repository_id => nil,
      )
    elsif action == "edit_github"
      project.update(
          :version_repository_id => nil,
      )
    else
      respond_to do |format|
        format.html { redirect_to projects_path, notice: DELETE_PROJECT_ERROR_MESSAGE }
      end
    end
    respond_to do |format|
      format.html { redirect_to projects_path, notice: DELETE_PROJECT_MESSAGE }
    end
  end

  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'プロジェクト情報を変更しました' }
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
      format.html { redirect_to projects_url, notice: 'プロジェクト情報を削除しました' }
      format.json { head :no_content }
    end
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(
      :name,
      :project_start_date,
      :user_id
    )
  end
end
