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

    # Redmineへの問い合わせ
    req = RestClient::Request.execute method: :get, url: @redmine_info[:url]+'/users.json', user: @redmine_info[:user], password: @redmine_info[:password]
    hash = JSON.parse(req)

    @redmine_info[:project] = 'sample1'

    # 存在するチケット数を取得
    total_issue_count = JSON.parse(RestClient::Request.execute method: :get, url: @redmine_info[:url]+'/issues.json', user: @redmine_info[:user], password: @redmine_info[:password])['total_count']

    # すべてのチケット情報を取得

    @tracker_info = Hash.new
    @tracker_info[:test] = total_issue_count

    ##########################
    # チケット情報のグラフ化 #
    ##########################

    # トラッカー名
    @tracker_info[:category] = ['Bug', 'Feature', 'Test']
    gon.tracker = @tracker_info[:category]

    # 各トラッカーのチケット消化数
    @tracker_info[:ticket_num] = [20, 8, 13]
    gon.ticket_num = @tracker_info[:ticket_num]

    # 消化チケットの総数
    @tracker_info[:ticket_num_all] = 0
    for n in @tracker_info[:ticket_num] do
      @tracker_info[:ticket_num_all] += n;
    end
    gon.ticket_num_all = @tracker_info[:ticket_num_all]

    # 開発者名
    @tracker_info[:developer] = '玄葉 条士郎'
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
