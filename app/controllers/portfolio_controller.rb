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

  def productivity_ajax
    #画面からデータの取得
    if request.xhr?
      projectId   = params['projectId']

      @redmine_info = Hash.new
      @redmine_info[:id] = Project.find_by_sql("SELECT ticket_repository_id FROM projects WHERE id = "+projectId)[0].ticket_repository_id
      @redmine_info[:url] = TicketRepository.find_by_sql("SELECT host_name FROM ticket_repositories WHERE id = "+@redmine_info[:id].to_s)[0].host_name
      @redmine_info[:login_id] = RedmineKey.find_by_sql("SELECT login_id FROM redmine_keys WHERE ticket_repository_id = "+@redmine_info[:id].to_s)[0].login_id
      @redmine_info[:password_digest] = RedmineKey.decrypt(RedmineKey.find_by_sql("SELECT password_digest FROM redmine_keys WHERE ticket_repository_id = "+@redmine_info[:id].to_s)[0].password_digest)

      @project = Hash.new
      # プロジェクト名を取得
      @project[:name] = TicketRepository.find_by_sql("SELECT project_name FROM ticket_repositories WHERE id = "+@redmine_info[:id].to_s)[0].project_name

      # 開発者の一覧をRedmineから取得
      developer_info = JSON.parse(RestClient::Request.execute method: :get, url: @redmine_info[:url] + '/users.json',
                                                              user: @redmine_info[:login_id], password: @redmine_info[:password_digest])['users']

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
      tracker_req = RestClient::Request.execute method: :get, url: @redmine_info[:url] + '/trackers.json', user: @redmine_info[:login_id], password: @redmine_info[:password_digest]
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

      # 各対象開発者情報の統計
      for developer in developer_info do
        redmine_developers.push(developer['lastname'] + developer['firstname'])

        roop_issues_Arr = []
        first_issues_json = JSON.parse(RestClient::Request.execute method: :get, url: redmine_url+'/issues.json?status_id=*&limit=100&assigned_to_id='+ developer['id'].to_s, user: @redmine_info[:login_id], password: @redmine_info[:password_digest])

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
          issue_offset = issue_offset + roop_limit
          issues_req = RestClient::Request.execute method: :get, url: redmine_url+'/issues.json?status_id=*&offset='+ issue_offset +'&limit=100&assigned_to_id='+ developer['id'].to_s, user: @redmine_info[:login_id], password: @redmine_info[:password_digest]
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

      finalStr = "{\"developers\":" + redmine_developers.to_s + ",\"trackers\":" + @productivity_info[:tracker].to_s + ",\"prospect\":" + prospect.to_s + ",\"result\":" + result.to_s + "}"

      puts finalStr

      render :json => JSON.parse(finalStr)

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
      projectId   = params['projectId']
      developerId = params['developerId']
      #issuesの状態
      stateArg = "all"

      #開発者メールアドレスの取得
      developer_email = Developer.find_by_sql("SELECT email FROM developers WHERE id = "+developerId)[0].email

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
