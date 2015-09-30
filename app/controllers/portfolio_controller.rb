class PortfolioController < ApplicationController
  def index
  end

  def ticket_digestion
    @tracker_info = Hash.new

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
    issuesArr = []
    first_issues_req = RestClient::Request.execute method: :get, url: redmine_url+'/issues.json?status_id=*&limit=100&assigned_to_id='+ developer_redmineId.to_s, user: redmineName, password: redminePW

    first_issues_json = JSON.parse(first_issues_req)

    first_issues_json['issues'].each do |issue|
      issuesArr.push(issue)
    end

    #ページの最初のデータのindex
    issue_offset = 0
    #総数
    total_count = first_issues_json['total_count']
    #各ページ表示する最大値
    limit = first_issues_json['limit']

    #issueのpagination処理    issueが多すぎ状態を回避するため
    while total_count > limit do
      issue_offset = issue_offset + limit
      issues_req = RestClient::Request.execute method: :get, url: redmine_url+'/issues.json?status_id=*&offset='+ issue_offset +'&limit=100&assigned_to_id='+ developer_redmineId.to_s+'&off', user: redmineName, password: redminePW
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
    result_req = RestClient::Request.execute method: :get, url: redmine_url+'/time_entries.json?limit=100', user: redmineName, password: redminePW
    result_json = JSON.parse(result_req)

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
      result_json['time_entries'].each do |time_entry|
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

    puts result_hours_result

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
