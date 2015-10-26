class PortfolioController < ApplicationController

  def index
    @project_id = params[:project_info][:project_id]
    @developer_id = params[:developer_id]
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
    @project_id = params[:project_info][:project_id]
    @developer_id = params[:developer_id]
  end

  def ticket_digestion_ajax
    #画面からデータの取得
    if request.xhr?
      projectId   = params['projectId']
      developerId = params['developerId']
      ######################
      # チケット情報の取得 #
      ######################

      # Redmineの認証情報を取得
      @redmine_info = Hash.new
      @redmine_info[:id] = Project.find_by_sql("SELECT ticket_repository_id FROM projects WHERE id = "+projectId)[0].ticket_repository_id
      @redmine_info[:url] = TicketRepository.find_by_sql("SELECT url FROM ticket_repositories WHERE id = "+@redmine_info[:id].to_s)[0].url
      @redmine_info[:login_id] = RedmineKey.find_by_sql("SELECT login_id FROM redmine_keys WHERE ticket_repository_id = "+@redmine_info[:id].to_s)[0].login_id
      @redmine_info[:password_digest] = RedmineKey.find_by_sql("SELECT password_digest FROM redmine_keys WHERE ticket_repository_id = "+@redmine_info[:id].to_s)[0].password_digest

      @project = Hash.new

      # プロジェクト名を取得
      @project[:name] = Project.find_by_sql("SELECT name FROM projects WHERE id = "+projectId)[0].name
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
      @developer[:id] = developerId
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

      #*************************************Redmineアカウント情報の取得
      #redmine上のアカウントID
      developer_redmineId = @developer[:id]

      #redmine上の全てのアカウントを取得し、その中から該当開発者のIDをもらう
      redmine_url = @redmine_info[:url] + "projects/" + @project[:name].downcase

      #redmine上の該当開発者の全てのissue情報を取得する

      #全てのissue情報を保存するarray、最後json形式に変更する
      issuesArr = []

      first_issues_req = RestClient::Request.execute method: :get, url: redmine_url+'/issues.json?status_id=*&limit=100&assigned_to_id='+ developer_redmineId.to_s, user: @redmine_info[:login_id], password: @redmine_info[:password_digest]
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
        issues_req = RestClient::Request.execute method: :get, url: redmine_url+'/issues.json?status_id=*&offset='+ issue_offset + '&limit=100&assigned_to_id='+ developer_redmineId.to_s, user: @redmine_info[:login_id], password: @redmine_info[:password_digest]
        total_count = total_count - limit
        JSON.parse(issues_req)['issues'].each do |issue|
          issuesArr.push(issue)
        end
      end

      all_ticket_info = JSON.parse(issuesArr.to_json)

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

      for i in all_ticket_info do
        if (!(i['assigned_to'].nil?))
          if (i['assigned_to']['id'] == @developer[:id])
            @issue_info[:count][i['tracker']['id']-1] += 1
          end
        end
      end

      # 消化チケットの総数
      @issue_info[:total_count] = 0
      for n in @issue_info[:count] do
        @issue_info[:total_count] += n;
      end

      finalStr = "{\"ticket_num\":" + @issue_info[:count].to_s + ",\"tracker\":" + @tracker[:name].to_s + ",\"ticket_num_all\":" + @issue_info[:total_count].to_s + ",\"projectName\":\"" + @project[:name] + "\",\"firstName\":\"" + @developer[:firstname] + "\",\"lastName\":\"" + @developer[:lastname] + "\"}"

      render :json => finalStr
    end
  end

  def productivity
    @developer_name = "SYU"
  end

  def productivity_ajax
    #画面からデータの取得
    if request.xhr?
      projectId   = params['projectId']
      developerId = params['developerId']

      @redmine_info = Hash.new
      @redmine_info[:id] = Project.find_by_sql("SELECT ticket_repository_id FROM projects WHERE id = "+projectId)[0].ticket_repository_id
      @redmine_info[:url] = TicketRepository.find_by_sql("SELECT url FROM ticket_repositories WHERE id = "+@redmine_info[:id].to_s)[0].url
      @redmine_info[:login_id] = RedmineKey.find_by_sql("SELECT login_id FROM redmine_keys WHERE ticket_repository_id = "+@redmine_info[:id].to_s)[0].login_id
      @redmine_info[:password_digest] = RedmineKey.find_by_sql("SELECT password_digest FROM redmine_keys WHERE ticket_repository_id = "+@redmine_info[:id].to_s)[0].password_digest

      @project = Hash.new
      # プロジェクト名を取得
      @project[:name] = Project.find_by_sql("SELECT name FROM projects WHERE id = "+projectId)[0].name

      # 開発者情報を取得
      @developer = Hash.new

      # 開発者のメールアドレスを取得
      @developer[:id] = developerId
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

      #*************************************Redmineアカウント情報、tracker情報の取得
      #redmine上のアカウントID
      developer_redmineId = @developer[:id]

      #redmine上の全てのアカウントを取得し、その中から該当開発者のIDをもらう
      redmine_url = @redmine_info[:url] + "projects/" + @project[:name].downcase

      #redmine上の該当開発者の全てのissue情報を取得する

      #全てのissue情報を保存するarray、最後json形式に変更する
      issuesArr = []

      first_issues_req = RestClient::Request.execute method: :get, url: redmine_url+'/issues.json?status_id=*&limit=100&assigned_to_id='+ developer_redmineId.to_s, user: @redmine_info[:login_id], password: @redmine_info[:password_digest]
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
        issues_req = RestClient::Request.execute method: :get, url: redmine_url+'/issues.json?status_id=*&offset='+ issue_offset +'&limit=100&assigned_to_id='+ developer_redmineId.to_s, user: @redmine_info[:login_id], password: @redmine_info[:password_digest]
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
      tracker_req = RestClient::Request.execute method: :get, url: @redmine_info[:url] + '/trackers.json', user: @redmine_info[:login_id], password: @redmine_info[:password_digest]
      tracker_json = JSON.parse(tracker_req)

      tracker_json['trackers'].each do |tracker|
        @productivity_info[:tracker].push(tracker['name'])
      end

      #予定工数Hash
      estimated_hours = Hash.new
      #実績工数Hash
      result_hours = Hash.new

      #実績工数情報の取得

      #全てのtime entry情報を保存するarray、最後json形式に変更する
      time_entry_Arr = []

      first_time_entry_req = RestClient::Request.execute method: :get, url: redmine_url+'/time_entries.json?limit=100', user: @redmine_info[:login_id], password: @redmine_info[:password_digest]
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
        time_entry_req = RestClient::Request.execute method: :get, url: redmine_url+'/time_entries.json?limit=100&offset='+ time_entry_offset.to_s, user: @redmine_info[:login_id], password: @redmine_info[:password_digest]
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

      finalStr = "{\"estimated_hours_result\":"

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

      finalStr.concat(estimated_hours_result.to_s + ",\"result_hours_result\":" + result_hours_result.to_s + ",\"tracker\":" + @productivity_info[:tracker].to_s + "}");

      render :json => finalStr

    end

  end

  def commits_ajax
    if request.xhr?
      projectId   = params['projectId']
      developerId = params['developerId']

      #repo設定
      @version_repo_id = Project.find(projectId)[:version_repository_id]
      repo_url = VersionRepository.find(@version_repo_id)[:url]
      githubRepo = repo_url.gsub(/https:\/\/github.com\//,'')

      #システム利用者github認証
      githubUserName = GithubKey.where(version_repository_id: @version_repo_id).pluck(:login_id).first
      githubUserPW = GithubKey.where(version_repository_id: @version_repo_id).pluck(:password_digest).first

      #認証を取る
      Octokit.configure do |c|
        c.login = githubUserName
        c.password = githubUserPW
      end

      #開発者メールアドレスの取得
      developer_email = Developer.find_by_sql("SELECT email FROM developers WHERE id = "+developerId)[0].email

      #チーム内開発者の全て開発者名前とコミット情報を取る
      Octokit.auto_paginate = true
      contributors = Octokit.contribs(githubRepo)

      #対象開発者の名前
      developer_name = ""

      #全員のコミット数
      total_commits = 0

      #対象開発者のコミット数
      developer_commits = 0

      #チーム内開発者総数
      total_developers = contributors.length

      #各開発者のメールアドレスを取得し、対象開発者のアドレスと比較する
      contributors.each do |contributor|
        developer_detail = JSON.parse(RestClient::Request.execute method: :get, url: 'https://api.github.com/users/' + contributor['login'], user: githubUserName, password: githubUserPW)
        total_commits = total_commits + contributor['contributions']
        if developer_email == developer_detail['email'] then
          developer_name = developer_detail['login']
          developer_commits = developer_commits + contributor['contributions']
        end
      end

      #コミット率
      commits_rate = (developer_commits.to_f/total_commits.to_f * 100).round(3)

      @commit_info = Hash.new

      finalStr = "{\"all_commit\":" + total_commits.to_s + ",\"own_commit\":" + developer_commits.to_s + ",\"developer_name\":\"" + developer_name + "\",\"commit_rate\":" + commits_rate.to_s + ",\"total_developers\":" + total_developers.to_s + "}"
      graphJson = JSON.parse(finalStr)
      render :json => graphJson
    end
  end

  def comments_ajax
    if request.xhr?
      projectId   = params['projectId']
      developerId = params['developerId']
      #issuesの状態
      stateArg = "all"

      #開発者メールアドレスの取得
      developer_email = Developer.find_by_sql("SELECT email FROM developers WHERE id = "+developerId)[0].email

      #repo設定
      @version_repo_id = Project.find(projectId)[:version_repository_id]
      repo_url = VersionRepository.find(@version_repo_id)[:url]

      #システム利用者github認証
      githubUserName = GithubKey.where(version_repository_id: @version_repo_id).pluck(:login_id).first
      githubUserPW = GithubKey.where(version_repository_id: @version_repo_id).pluck(:password_digest).first

      githubRepo = repo_url.gsub(/https:\/\/github.com\//,'')

      #認証を取る
      Octokit.configure do |c|
        c.login = githubUserName
        c.password = githubUserPW
      end

      # API 呼び出し回数
      ratelimit           = Octokit.ratelimit
      ratelimit_remaining = Octokit.ratelimit_remaining
      puts "Rate Limit Remaining: #{ratelimit_remaining} / #{ratelimit}"
      puts

      #チーム内開発者の全て開発者名前を取る
      Octokit.auto_paginate = true
      contributors = Octokit.contribs(githubRepo)

      #見たい開発者のGithub上のUserName
      @assigneeArg = ""

      contributors.each do |contributor|
        developer_detail = JSON.parse(RestClient::Request.execute method: :get, url: 'https://api.github.com/users/' + contributor['login'], user: githubUserName, password: githubUserPW)
        if developer_email == developer_detail['email'] then
          @assigneeArg = developer_detail['login']
        end
      end

      #同じリポジトリの中の他の開発者名前を取得する
      contributors = Octokit.contribs(githubRepo)
      developer_name = Hash.new
      contributors.each do |contributor|
        if contributor['login'] != @assigneeArg then
          developer_name[contributor['login']] = 0
        end
      end

      #issue情報を取る
      Octokit.auto_paginate = true
      issues = Octokit.list_issues(githubRepo,state: stateArg)

      #最終json
      finalStr = ""
      nodes = ""
      links = ""

      issues.each do |issue|

        #assigneeArgが担当しなかった,かつ comment数は0ではない,かつ 担当者がnilではないissueの一覧表示
        if issue['assignee'] != nil && issue['assignee']['login'] != @assigneeArg && issue['comments'] != 0 then
          #各issueのcommentsの取得
          comments = Octokit.issue_comments(githubRepo, issue['number'].to_s)
          counter = 0
          #commentsから該当開発者の発言を合計する
          comments.each do |comment|
            if comment['user']['login'] == @assigneeArg
              counter = counter + 1
            end
          end

          #comment数を分類する
          if counter != 0 then
            developer_name.each_pair {|name, num|
              if name == issue['assignee']['login'] then
                developer_name[name] = developer_name[name] + counter
              end
            }
          end

        end
      end

      #該当開発者の設定
      nodes.concat("{\"nodes\":[{\"name\":\"" + @assigneeArg + "\",\"group\":3}")
      links.concat("],\"links\":[{\"source\":0,\"target\":")
      loopTime = 0

      developer_name.each_pair {|name, num|
        if loopTime < developer_name.length then
          nodes.concat(",{\"name\":\"" + name + "\",\"group\":2}")
          links.concat((loopTime + 1).to_s + ",\"value\":")
          if loopTime != developer_name.length - 1 then
            links.concat(num.to_s + "},{\"source\":0,\"target\":")
          else
            links.concat(num.to_s + "}]}")
          end
          loopTime = loopTime + 1
        end
      }

      finalStr = nodes + links

      render :json => finalStr

    end

  end
end
