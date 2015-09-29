class PortfolioController < ApplicationController
  def index
  end

  def ticket_digestion
    ######################
    # チケット情報の取得 #
    ######################

    # Redmineの認証情報
    @redmine_info = Hash.new
    @redmine_info[:url] = 'test-vibi-redmine.herokuapp.com'
    @redmine_info[:user] = 'admin'
    @redmine_info[:password] = 'admin'

    # プロジェクトの識別子を取得
    @project = Hash.new

    # プロジェクト名
    @project[:name] = 'サンプルプロジェクト1'

    project_info = JSON.parse(RestClient::Request.execute method: :get, url: @redmine_info[:url]+'/projects.json',
                                user: @redmine_info[:user], password: @redmine_info[:password])['projects']

    for project in project_info do
      if (project['name'] == @project[:name])
        @project[:identifier] = project['identifier']
      end
    end

    # 開発者情報を取得
    @developer = Hash.new

    # 開発者のメールアドレス
    @developer[:mail] = 'admin@example.net'

    # 開発者の一覧をRedmineから取得
    developer_info = JSON.parse(RestClient::Request.execute method: :get, url: @redmine_info[:url]+'/users.json',
                           user: @redmine_info[:user], password: @redmine_info[:password])['users']

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
                                   user: @redmine_info[:user], password: @redmine_info[:password])['total_count']

    # すべてのチケット情報を取得
    all_ticket_info = JSON.parse(RestClient::Request.execute method: :get, url: @redmine_info[:url]+'/projects/'+@project[:identifier]+'/issues.json?status_id=*&limit='+total_issue_count.to_s,
                                 user: @redmine_info[:user], password: @redmine_info[:password])

    # トラッカーの一覧を取得
    tracker_info = JSON.parse(RestClient::Request.execute method: :get, url: @redmine_info[:url]+'/trackers.json', user: @redmine_info[:user], password: @redmine_info[:password])
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
