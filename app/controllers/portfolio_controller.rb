class PortfolioController < ApplicationController

  def index
    #@project_id = params[:project_info][:project_id]
    @developer_id = params[:developer_info][:id]

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

  def productivity_info
    @developer = Developer.all
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
      @redmine_info[:url] = TicketRepository.find_by_sql("SELECT host_name FROM ticket_repositories WHERE id = "+@redmine_info[:id].to_s)[0].host_name
      @redmine_info[:login_id] = RedmineKey.find_by_sql("SELECT login_id FROM redmine_keys WHERE ticket_repository_id = "+@redmine_info[:id].to_s)[0].login_id
      @redmine_info[:password_digest] = RedmineKey.decrypt(RedmineKey.find_by_sql("SELECT password_digest FROM redmine_keys WHERE ticket_repository_id = "+@redmine_info[:id].to_s)[0].password_digest)

      @project = Hash.new

      # プロジェクト名を取得
      @project[:name] = TicketRepository.find_by_sql("SELECT project_name FROM ticket_repositories WHERE id = "+@redmine_info[:id].to_s)[0].project_name

      # 開発者情報を取得
      @developer = Hash.new

      # 開発者のメールアドレスを取得
      @developer[:id] = developerId
      @developer[:mail] = Developer.find_by_sql("SELECT email FROM developers WHERE id = "+@developer[:id])[0].email

      # 開発者の一覧をRedmineから取得
      developer_info = JSON.parse(RestClient::Request.execute method: :get, url: @redmine_info[:url] + '/users.json',
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
      redmine_url = @redmine_info[:url] + '/projects/'+ @project[:name]

      #redmine上の該当開発者の全てのissue情報を取得する

      #全てのissue情報を保存するarray、最後json形式に変更する
      issuesArr = []

      first_issues_req = RestClient::Request.execute method: :get, url: redmine_url + '/issues.json?status_id=*&limit=100&assigned_to_id='+ developer_redmineId.to_s, user: @redmine_info[:login_id], password: @redmine_info[:password_digest]
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
      tracker_info = JSON.parse(RestClient::Request.execute method: :get, url: @redmine_info[:url] + '/trackers.json', user: @redmine_info[:login_id], password: @redmine_info[:password_digest])
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

  def productivity_ajax
    #画面からデータの取得
    if request.xhr?
      projectId   = params['projectId']
      developerId = params['developerId']

      @redmine_info = Hash.new
      @redmine_info[:id] = Project.find_by_sql("SELECT ticket_repository_id FROM projects WHERE id = "+projectId)[0].ticket_repository_id
      @redmine_info[:url] = TicketRepository.find_by_sql("SELECT host_name FROM ticket_repositories WHERE id = "+@redmine_info[:id].to_s)[0].host_name
      @redmine_info[:login_id] = RedmineKey.find_by_sql("SELECT login_id FROM redmine_keys WHERE ticket_repository_id = "+@redmine_info[:id].to_s)[0].login_id
      @redmine_info[:password_digest] = RedmineKey.decrypt(RedmineKey.find_by_sql("SELECT password_digest FROM redmine_keys WHERE ticket_repository_id = "+@redmine_info[:id].to_s)[0].password_digest)

      @project = Hash.new
      # プロジェクト名を取得
      @project[:name] = TicketRepository.find_by_sql("SELECT project_name FROM ticket_repositories WHERE id = "+@redmine_info[:id].to_s)[0].project_name

      # 開発者情報を取得
      @developer = Hash.new

      # 開発者のメールアドレスを取得
      @developer[:id] = developerId
      @developer[:mail] = Developer.find_by_sql("SELECT email FROM developers WHERE id = "+@developer[:id])[0].email

      # 開発者の一覧をRedmineから取得
      developer_info = JSON.parse(RestClient::Request.execute method: :get, url: @redmine_info[:url] + '/users.json',
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
      redmine_url = @redmine_info[:url] + '/projects/'+ @project[:name]

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

      arr_index = 0

      while arr_index < estimated_hours_result.length do
        if estimated_hours_result[arr_index] == 0 && result_hours_result[arr_index] == 0
          estimated_hours_result[arr_index] = -1
          result_hours_result[arr_index] = -1
          @productivity_info[:tracker][arr_index] = 'unshow'
        end
        arr_index = arr_index + 1
      end
      
      estimated_hours_result.delete(-1)
      result_hours_result.delete(-1)
      @productivity_info[:tracker].delete('unshow')

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
      githubRepo = VersionRepository.find(@version_repo_id)[:project_name] + '/' + VersionRepository.find(@version_repo_id)[:repository_name]

      #システム利用者github認証
      githubUserName = GithubKey.where(version_repository_id: @version_repo_id).pluck(:login_id).first
      githubUserPW = RedmineKey.decrypt(GithubKey.where(version_repository_id: @version_repo_id).pluck(:password_digest).first)

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
      # TODO: 変数はスネークで記述します
      target_project = Project.find_by(id: params['projectId'])

      # 認証
      login_id = target_project.version_repository.github_keys.first.login_id
      password = RedmineKey.decrypt(target_project.version_repository.github_keys.first.password_digest)
      Octokit.configure do |f|
        f.login    = login_id
        f.password = password
      end

      # API呼び出し回数制限表示
      ratelimit           = Octokit.ratelimit
      ratelimit_remaining = Octokit.ratelimit_remaining
      puts "Rate Limit Remaining: #{ratelimit_remaining} / #{ratelimit}"

      project_name    = target_project.version_repository.project_name
      repository_name = target_project.version_repository.repository_name
      version_repository = project_name + '/' + repository_name

      # チーム内開発者の全て開発者名前を取る
      Octokit.auto_paginate = true
      contributors = Octokit.contribs(version_repository)

      # 開発者取得
      # TODO: 開発者とプロジェクトのリレーションなってない..
      assign_logs = AssignLog.where(project_id: target_project).pluck(:id)
      developers_email = Developer.where(id: assign_logs).pluck(:email)

      # 表示する開発者
      show_developers = []
      contributors.each do |contributor|
        contributor_data = JSON.parse(RestClient::Request.execute method: :get,
                                      url: 'https://api.github.com/users/' + contributor['login'],
                                      user: login_id,
                                      password: password)
        show_developers << contributor_data['login'] if developers_email.include?(contributor['email'])
      end

      #issue情報を取る
      issues = Octokit.list_issues(version_repository, state: 'all')

      issue_comment_data = Hash.new { |h,k| h[k] = {} }
      binding.pry
      developer_name = Hash.new
      contributors.each do |contributor|
        if contributor['login'] != @assigneeArg
          developer_name[contributor['login']] = 0
        end
      end
      issues.each do |issue|
        show_developers.each do |show_developer|
          show_developer = []
          # comment数は0ではない＆担当者がnilではないissueの一覧表示
          if issue['assignee'] != nil && issue['comments'] != 0 && show_developer
            # 各issueのcommentsの取得
            comments = Octokit.issue_comments(version_repository, issue['number'].to_s)
            count = 0
            # commentsから該当開発者の発言を合計する
            comments.each do |comment|
              show_developers.each do |receiver|
                count += 1 if comment['user']['login'] == receiver
              end
            end

            # comment数を分類する
            if count != 0
              developer_name.each_pair {|name, num|
                if name == issue['assignee']['login']
                  developer_name[name] = developer_name[name] + count
                end
              }
            end
          end
        end
      end

      render :json => issue_comment_data
    end
  end
end
