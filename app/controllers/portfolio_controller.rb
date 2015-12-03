class PortfolioController < ApplicationController

  def index
    projects = []
    Project.all.each do |project|
      projects << project if ApplicationController.helpers.show_project?(current_user, project)
    end
    @projects = projects
    redirect_to '/projects/new', notice: NO_PROJECT if projects.blank?
  end

  def setting
    projects = []
    Project.all.each do |project|
      projects << project if ApplicationController.helpers.show_project?(current_user, project)
    end
    redirect_to '/projects/new', notice: NO_PROJECT if projects.blank?
  end

  def productivity_ajax
    #画面からデータの取得
    if request.xhr?
      projectId = params['project_id']

      @redmine_info = Hash.new
      @redmine_info[:id] = Project.find_by(id: projectId).ticket_repository_id
      @redmine_info[:url] = TicketRepository.find_by(id: @redmine_info[:id]).host_name
      @redmine_info[:login_id] = RedmineKey.find_by(ticket_repository_id: @redmine_info[:id]).login_id
      @redmine_info[:password_digest] = RedmineKey.decrypt(RedmineKey.find_by(ticket_repository_id: @redmine_info[:id]).password_digest)

      @project = Hash.new

      # プロジェクト名(識別子)を取得する
      @project[:name] = TicketRepository.find_by(id: @redmine_info[:id]).project_name

      #プロジェクト名(識別子)からredmine上のprojectIdを所得する
      redmine_projects = JSON.parse(RestClient::Request.execute method: :get,
                                    url: @redmine_info[:url]  + '/projects.json',
                                    user: @redmine_info[:login_id],
                                    password: @redmine_info[:password_digest])['projects']

      for project in redmine_projects do
        if @project[:name] == project['identifier'] then
          redmine_project_id = project['id']
        end
      end

      #全てのmemebership情報を保存するarray、最後json形式に変更する
      membership_Arr = []
      # 開発者の一覧をRedmineから取得
      developer_info = JSON.parse(RestClient::Request.execute method: :get,
                                  url: @redmine_info[:url] + '/projects/' + @project[:name] + '/memberships.json?limit=100',
                                  user: @redmine_info[:login_id],
                                  password: @redmine_info[:password_digest])

      developer_info['memberships'].each do |membership|
        membership_Arr.push(membership)
      end

      #最初のデータのindex
      membership_offset = 0
      #総数
      membership_total_count = developer_info['total_count']
      #一回問い合わせする最大値
      membership_limit = developer_info['limit']

      #membershipのpagination処理
      while membership_total_count > membership_limit do
        membership_offset = membership_offset + membership_limit
        membership_req = RestClient::Request.execute method: :get,
                         url: @redmine_info[:url] + '/projects/' + @project[:name] + '/memberships.json?limit=100',
                         user: @redmine_info[:login_id],
                         password: @redmine_info[:password_digest]
        membership_total_count = membership_total_count - membership_limit

        JSON.parse(membership_req)['memberships'].each do |membership|
          membership_Arr.push(membership)
        end
      end

      membership_json = JSON.parse(membership_Arr.to_json)

      # Redmine開発者リスト
      redmine_developers = []
      # 予定工数Array
      prospect = []
      # 実際工数Array
      result = []

      # トラッカーHash
      @productivity_info = Hash.new
      @productivity_info[:tracker] = []

      # トラッカー名の取得
      tracker_req = RestClient::Request.execute method: :get,
        url: @redmine_info[:url] + '/trackers.json',
        user: @redmine_info[:login_id],
        password: @redmine_info[:password_digest]
      tracker_json = JSON.parse(tracker_req)

      tracker_json['trackers'].each do |tracker|
        @productivity_info[:tracker].push(tracker['name'])
      end

      redmine_url = @redmine_info[:url] + '/projects/'+ @project[:name]

      #予定工数Hash
      estimated_hours = Hash.new
      #実績工数Hash
      result_hours = Hash.new

      #実績工数情報の取得

      #全てのtime entry情報を保存するarray、最後json形式に変更する
      time_entry_Arr = []

      first_time_entry_req = RestClient::Request.execute method: :get,
        url: redmine_url+'/time_entries.json?limit=100',
        user: @redmine_info[:login_id],
        password: @redmine_info[:password_digest]
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
        time_entry_req = RestClient::Request.execute method: :get,
          url: redmine_url+'/time_entries.json?limit=100&offset='+ time_entry_offset.to_s,
          user: @redmine_info[:login_id],
          password: @redmine_info[:password_digest]
        time_entry_total_count = time_entry_total_count - time_entry_limit
        JSON.parse(time_entry_req)['time_entries'].each do |time_entry|
          time_entry_Arr.push(time_entry)
        end
      end

      time_entry_json = JSON.parse(time_entry_Arr.to_json)

      # 各対象開発者情報の統計
      for developer in membership_json do
        if developer['project']['id'] == redmine_project_id && developer['user'] then
          redmine_developers.push(developer['user']['name'])

          roop_issues_Arr = []
          first_issues_json = JSON.parse(RestClient::Request.execute method: :get,
                                                                     url: redmine_url+'/issues.json?status_id=*&limit=100&assigned_to_id='+ developer['user']['id'].to_s,
                                                                     user: @redmine_info[:login_id],
                                                                     password: @redmine_info[:password_digest])

          first_issues_json['issues'].each do |issue|
            roop_issues_Arr.push(issue)
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
            issues_req = RestClient::Request.execute method: :get,
                                                     url: redmine_url+'/issues.json?status_id=*&offset='+ issue_offset +'&limit=100&assigned_to_id='+ developer['user']['id'].to_s,
                                                     user: @redmine_info[:login_id],
                                                     password: @redmine_info[:password_digest]
            total_count = total_count - limit
            JSON.parse(roop_issues_req)['issues'].each do |issue|
              roop_issues_Arr.push(issue)
            end
          end

          # 対象者の全てのissue
          issues_json = JSON.parse(roop_issues_Arr.to_json)

          #予定工数Hash
          roop_estimated_hours = Hash.new
          #実績工数Hash
          roop_result_hours = Hash.new

          #工数Hash初期化
          @productivity_info[:tracker].each do |tracker|
            roop_estimated_hours[tracker] = 0
            roop_result_hours[tracker] = 0
          end

          #*************************************************工数計算部分
          #予定工数の計算
          issues_json.each do |issue|

            #予定工数計算部分
            if nil != issue['estimated_hours'] then
              roop_estimated_hours[issue['tracker']['name']] = roop_estimated_hours[issue['tracker']['name']] + issue['estimated_hours']
            end

            #実績工数計算部分
            time_entry_json.each do |time_entry|
              if issue['id'] == time_entry['issue']['id'] then
                roop_result_hours[issue['tracker']['name']] = roop_result_hours[issue['tracker']['name']] + time_entry['hours']
              end
            end

          end

          #予定工数Arrayの設定
          roop_estimated_hours_result = []
          roop_estimated_hours.each{|key, value|
            roop_estimated_hours_result.push(value)
          }
          #実績工数Arrayの設定
          roop_result_hours_result = []
          roop_result_hours.each{|key, value|
            roop_result_hours_result.push(value)
          }

          prospect.push(roop_estimated_hours_result)
          result.push(roop_result_hours_result)
        end
      end

      finalStr = "{\"developers\":" + redmine_developers.to_s + ",\"trackers\":" + @productivity_info[:tracker].to_s + ",\"prospect\":" + prospect.to_s + ",\"result\":" + result.to_s + "}"

      render :json => JSON.parse(finalStr)
    end

  end

  def commits_ajax
    if request.xhr?
      projectId   = params['project_id']

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

      # 開発者リスト
      developers_array = []
      # 各開発者のコミット数リスト
      commit_array = []

      all_developer_commits = JSON.parse(RestClient::Request.execute method: :get, url: 'api.github.com/repos/' + githubRepo + '/stats/contributors', user: githubUserName, password: githubUserPW)

      all_developer_commits.each do |contributor|
        developers_array.push(contributor['author']['login'])
        commit_array.push(contributor['total'])
      end

      finalStr = "{\"developers\":" + developers_array.to_s + ",\"commit_count\":" + commit_array.to_s + "}"

      graphJson = JSON.parse(finalStr)
      render :json => graphJson
    end
  end

  def comments_ajax
    if request.xhr?
      # TODO: 変数はスネークで記述します
      target_project = Project.find_by(id: params['project_id'])

      # 認証
      login_id = target_project.version_repository.github_keys.first.login_id
      password = RedmineKey.decrypt(
        target_project.version_repository.github_keys.first.password_digest
      )
      Octokit.configure do |f|
        f.login    = login_id
        f.password = password
      end

      # API呼び出し回数制限表示
      ratelimit           = Octokit.ratelimit
      ratelimit_remaining = Octokit.ratelimit_remaining
      puts "残り回数: #{ratelimit_remaining} / #{ratelimit}"

      project_name    = target_project.version_repository.project_name
      repository_name = target_project.version_repository.repository_name
      version_repository = project_name + '/' + repository_name

      # チーム内開発者の全て開発者名前を取る
      Octokit.auto_paginate = true
      contributors = Octokit.contribs(version_repository)

      # 開発者取得
      # TODO: 開発者とプロジェクトのリレーションなってない..
      assign_logs = AssignLog.where(project_id: target_project).pluck(:developer_id)
      developers_email = Developer.where(id: assign_logs).pluck(:email)

      # 表示する開発者
      show_developers = []
      contributors.each do |contributor|
        contributor_data = JSON.parse(RestClient::Request.execute method: :get,
                                      url: 'api.github.com/users/' + contributor['login'],
                                      user: login_id,
                                      password: password)
         if developers_email.include?(contributor_data['email'])
           show_developers << contributor_data['login']
         end
      end

      # issue情報を取る
      issue_comment_data = Hash.new { |h,k| h[k] = {} }

      show_developers.each do |speaker|
        show_developers.each do |receiver|
          issue_comment_data["#{speaker}"]["#{receiver}"] = 0
        end
      end

      issues = Octokit.list_issues(version_repository, state: 'all')
      issues.each do |issue|
        if issue['assignee'].present? && issue['comments'] != 0
          comment_user_data = []
          comments = Octokit.issue_comments(version_repository, issue['number'].to_s)
          comments.each do |comment|
            comment_user_data << comment['user']['login']
          end
          show_developers.each do |show_developer|
            count = comment_user_data.count(show_developer)
            if show_developers.include?(issue['assignee']['login'])
              issue_comment_data["#{show_developer}"]["#{issue['assignee']['login']}"] += count
            end
          end
          puts issue['number'].to_s
          puts issue_comment_data
        end
      end

      speaker_data = Hash.new { |h,k| h[k] = {} }
      speaker_data["speakers"] = []
      speaker_data["comments"] = []
      issue_comment_data.values.each_with_index do |comment, i|
        speaker_data["speakers"] << show_developers[i]
        speaker_data["comments"] << comment.values
      end
      render :json => speaker_data
    end
  end
end
