class PortfolioController < ApplicationController
  def index
  end

  def select_function
    if params[:id] == '1' then
      redirect_to '/commit_counter/index'
    elsif params[:id] == '2' then
      redirect_to '/comments_counter/index'
    elsif params[:id] == '3' then
      redirect_to '/portfolio/productivity_info'
    elsif params[:id] == '4' then
      redirect_to '/portfolio/productivity'
    end
  end

  def productivity_info
    @developer = Developer.all
  end

  def show_projects
    @info = Hash.new
    @info[:status] = true
    
    # プロジェクト情報を取得
    @project = Project.find_by_sql("SELECT projects.id, projects.name FROM projects, assign_logs WHERE assign_logs.project_id = projects.id AND assign_logs.developer_id = "+params[:developer_info][:id])
    if (@project.empty?)
      @info[:status] = false
    end

    @developer_info= Hash.new
    @developer_info[:id] = params[:developer_info][:id]
  end

  def ticket_digestion
    ######################
    # チケット情報の取得 #
    ######################

    # Redmineの認証情報を取得
    @redmine_info = Hash.new
    @redmine_info[:id] = Project.find_by_sql("SELECT ticket_repository_id FROM projects WHERE id = "+params[:project_info][:project_id])[0].ticket_repository_id
    @redmine_info[:url] = TicketRepository.find_by_sql("SELECT url FROM ticket_repositories WHERE id = "+@redmine_info[:id].to_s)[0].url
    @redmine_info[:login_id] = RedmineKey.find_by_sql("SELECT login_id FROM redmine_keys WHERE ticket_repository_id = "+@redmine_info[:id].to_s)[0].login_id
    @redmine_info[:password_digest] = RedmineKey.find_by_sql("SELECT password_digest FROM redmine_keys WHERE ticket_repository_id = "+@redmine_info[:id].to_s)[0].password_digest 

    @project = Hash.new

    # プロジェクト名を取得
    @project[:name] = Project.find_by_sql("SELECT name FROM projects WHERE id = "+params[:project_info][:project_id])[0].name
    project_info = JSON.parse(RestClient::Request.execute method: :get, url: @redmine_info[:url]+'/projects.json',
                                user: @redmine_info[:login_id], password: @redmine_info[:password_digest])['projects']

    # プロジェクトの識別子を取得
    for project in project_info do
      if (project['name'] == @project[:name])
        @project[:identifier] = project['identifier']
      end
    end

    # 開発者情報を取得
    @developer = Hash.new

    # 開発者のメールアドレスを取得
    @developer[:id] = params[:developer_id]
    @developer[:mail] = Developer.find_by_sql("SELECT email FROM developers WHERE id = "+@developer[:id])[0].email

    # 開発者の一覧をRedmineから取得
    developer_info = JSON.parse(RestClient::Request.execute method: :get, url: @redmine_info[:url]+'/users.json',
                           user: @redmine_info[:login_id], password: @redmine_info[:password_digest])['users']

    # 対象開発者情報の抽出
    for developer in developer_info do
      if (developer['mail'] == @developer[:mail])
        @developer[:id] = developer['id']
        @developer[:firstname] = developer['firstname']
        @developer[:lastname] = developer['lastname']
      end
    end

    # 存在するチケット数を取得
    total_issue_count = JSON.parse(RestClient::Request.execute method: :get, url: @redmine_info[:url]+'/projects/'+@project[:identifier]+'/issues.json?status_id=*',
                                   user: @redmine_info[:login_id], password: @redmine_info[:password_digest])['total_count']

    # すべてのチケット情報を取得
    all_ticket_info = JSON.parse(RestClient::Request.execute method: :get, url: @redmine_info[:url]+'/projects/'+@project[:identifier]+'/issues.json?status_id=*&limit='+total_issue_count.to_s,
                                 user: @redmine_info[:login_id], password: @redmine_info[:password_digest])

    # トラッカーの一覧を取得
    tracker_info = JSON.parse(RestClient::Request.execute method: :get, url: @redmine_info[:url]+'/trackers.json', user: @redmine_info[:login_id], password: @redmine_info[:password_digest])
    @tracker = Hash.new
    @tracker[:id] = Array.new
    @tracker[:name] = Array.new
    for tracker in tracker_info['trackers'] do
      @tracker[:id].push(tracker['id'])
      @tracker[:name].push(tracker['name'])
    end

    ##########################
    # チケット情報のグラフ化 #
    ##########################

    @issue_info = Hash.new

    # 各トラッカーのチケット消化数
    @issue_info[:count] = Array.new(@tracker[:id].length)

    for i in 1..@issue_info[:count].length do
      @issue_info[:count][i-1] = 0
    end

    for i in all_ticket_info['issues'] do
      if (!(i['assigned_to'].nil?))
        if (i['assigned_to']['id'] == @developer[:id])
          @issue_info[:count][i['tracker']['id']-1] += 1
        end
      end
    end

    gon.ticket_num = @issue_info[:count]

    # トラッカー名
    gon.tracker = @tracker[:name]

    # 消化チケットの総数
    @issue_info[:total_count] = 0
    for n in @issue_info[:count] do
      @issue_info[:total_count] += n;
    end
    gon.ticket_num_all = @issue_info[:total_count]
  end

  def productivity
    @productivity_info = Hash.new

    # トラッカー名
    @productivity_info[:tracker] = ['Bug', 'Feature', 'Test', 'Document']
    gon.tracker = @productivity_info[:tracker]

    # 実績工数
    @productivity_info[:result] = [120, 56, 79, 12]
    gon.task_result = @productivity_info[:result]

    # 予定工数
    @productivity_info[:estimate] = [100, 70, 70, 10]
    gon.task_estimate = @productivity_info[:estimate]

    # 開発者名
    @productivity_info[:developer] = '玄葉 条士郎'
  end
end
