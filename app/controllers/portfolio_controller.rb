require 'json'

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
    #***********************************************get ProductionCost

    #redmine上のアカウント名
    @developer_name = "SYU"
    #redmine上のアカウントID
    developer_redmineId = nil

    #redmine上認証
    redmineName = "zouyimin"
    redminePW = "z13299928050"

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
    issues_req = RestClient::Request.execute method: :get, url: redmine_url+'/issues.json?status_id=*&assigned_to_id='+ developer_redmineId.to_s, user: redmineName, password: redminePW

    issues_json = JSON.parse(issues_req)

    # トラッカーHash
    @productivity_info = Hash.new

    # トラッカー名
    @productivity_info[:tracker] = ['BUG', 'FEATURE', 'SUPPORT', 'DOCUMENT']
    gon.tracker = @productivity_info[:tracker]

    #実績工数Hash
    estimated_hours = Hash.new
    #実績工数Hash初期化
    @productivity_info[:tracker].each do |tracker|
      estimated_hours[tracker] = 0
    end

    #予定工数の計算
    issues_json['issues'].each do |issue|
      @productivity_info[:tracker].each do |tracker|
        if issue['tracker']['name'] == tracker then
          estimated_hours[tracker] = estimated_hours[tracker] + issue['estimated_hours']
        end
      end

    end

    #実績工数Array
    estimated_hours_result = []
    estimated_hours.each{|key, value|
      estimated_hours_result.push(value)
    }
    puts estimated_hours_result


    #******************************************************graph

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
