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
    @developer_name = "SYU"
  end

  def productivity_ajax
    #*************************************Redmineアカウント情報、tracker情報の取得
    #redmine上のアカウント名
    @developer_name = "SYU"
    #redmine上のアカウントID
    developer_redmineId = nil

    #redmine上認証
    redmineName = ENV['RedmineName']
    redminePW = ENV['RedminePW']

    #redmine上の全てのアカウントを取得し、その中から該当開発者のIDをもらう
    redmine_url = 'http://vibi-redmine.herokuapp.com/projects/vibi'
    memberships_req = RestClient::Request.execute method: :get, url: redmine_url+'/memberships.json', user: redmineName, password: redminePW

    # perse
    memberships_json = JSON.parse(memberships_req)

    memberships_json['memberships'].each do |membership|
      if membership['user']['name'] == @developer_name then
        developer_redmineId = membership['user']['id']
      end
    end

    #redmine上の該当開発者の全てのissue情報を取得する

    #全てのissue情報を保存するarray、最後json形式に変更する
    issuesArr = []

    first_issues_req = RestClient::Request.execute method: :get, url: redmine_url+'/issues.json?status_id=*&limit=100&assigned_to_id='+ developer_redmineId.to_s, user: redmineName, password: redminePW
    first_issues_json = JSON.parse(first_issues_req)

    #第一回問い合わせしてもらった情報をarrayに保存
    first_issues_json['issues'].each do |issue|
      issuesArr.push(issue)
    end

    #最初のデータのindex
    issue_offset = 0
    #総数
    total_count = first_issues_json['total_count']
    #一回問い合わせする最大値
    limit = first_issues_json['limit']

    #issueのpagination処理
    while total_count > limit do
      issue_offset = issue_offset + limit
      issues_req = RestClient::Request.execute method: :get, url: redmine_url+'/issues.json?status_id=*&offset='+ issue_offset +'&limit=100&assigned_to_id='+ developer_redmineId.to_s, user: redmineName, password: redminePW
      total_count = total_count - limit
      JSON.parse(issues_req)['issues'].each do |issue|
        issuesArr.push(issue)
      end
    end

    issues_json = JSON.parse(issuesArr.to_json)

    # トラッカーHash
    @productivity_info = Hash.new
    @productivity_info[:tracker] = []

    # トラッカー名の取得
    tracker_req = RestClient::Request.execute method: :get, url: 'http://vibi-redmine.herokuapp.com/trackers.json', user: redmineName, password: redminePW
    tracker_json = JSON.parse(tracker_req)

    tracker_json['trackers'].each do |tracker|
      @productivity_info[:tracker].push(tracker['name'])
    end

    gon.tracker = @productivity_info[:tracker]

    #予定工数Hash
    estimated_hours = Hash.new
    #実績工数Hash
    result_hours = Hash.new

    #実績工数情報の取得

    #全てのtime entry情報を保存するarray、最後json形式に変更する
    time_entry_Arr = []

    first_time_entry_req = RestClient::Request.execute method: :get, url: redmine_url+'/time_entries.json?limit=100', user: redmineName, password: redminePW
    first_time_entry_json = JSON.parse(first_time_entry_req)

    #第一回問い合わせしてもらった情報をarrayに保存
    first_time_entry_json['time_entries'].each do |time_entry|
      time_entry_Arr.push(time_entry)
    end

    #最初のデータのindex
    time_entry_offset = 0
    #総数
    time_entry_total_count = first_time_entry_json['total_count']
    #一回問い合わせする最大値
    time_entry_limit = first_time_entry_json['limit']

    #time entryのpagination処理
    while time_entry_total_count > time_entry_limit do
      time_entry_offset = time_entry_offset + time_entry_limit
      time_entry_req = RestClient::Request.execute method: :get, url: redmine_url+'/time_entries.json?limit=100&offset='+ time_entry_offset.to_s, user: redmineName, password: redminePW
      time_entry_total_count = time_entry_total_count - time_entry_limit
      JSON.parse(time_entry_req)['time_entries'].each do |time_entry|
        time_entry_Arr.push(time_entry)
      end
    end

    time_entry_json = JSON.parse(time_entry_Arr.to_json)

    #工数Hash初期化
    @productivity_info[:tracker].each do |tracker|
      estimated_hours[tracker] = 0
      result_hours[tracker] = 0
    end

    #*************************************************工数計算部分
    #予定工数の計算
    issues_json.each do |issue|

      #予定工数計算部分
      if nil != issue['estimated_hours'] then
        estimated_hours[issue['tracker']['name']] = estimated_hours[issue['tracker']['name']] + issue['estimated_hours']
      end

      #実績工数計算部分
      time_entry_json.each do |time_entry|
        if issue['id'] == time_entry['issue']['id'] then
          result_hours[issue['tracker']['name']] = result_hours[issue['tracker']['name']] + time_entry['hours']
        end
      end

    end

    #予定工数Arrayの設定
    estimated_hours_result = []
    estimated_hours.each{|key, value|
      estimated_hours_result.push(value)
    }
    #実績工数Arrayの設定
    result_hours_result = []
    result_hours.each{|key, value|
      result_hours_result.push(value)
    }

    #****************************************************graph

    # 実績工数
    @productivity_info[:result] = result_hours_result
    gon.task_result = @productivity_info[:result]

    # 予定工数
    @productivity_info[:estimate] = estimated_hours_result
    gon.task_estimate = @productivity_info[:estimate]

    # 開発者名
    @productivity_info[:developer] = @developer_name
  end
end
