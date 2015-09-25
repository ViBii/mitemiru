class CommitCounterController < ApplicationController
  def index
    #コミット数の集計処理をここに記載

    @commit_info = Hash.new

    # The number of commits
    # Sample data
    @commit_info[:own_commit] = 11
    @commit_info[:all_commit] = 90
    gon.own_commit = @commit_info[:own_commit]
    gon.all_commit = @commit_info[:all_commit]

    # Developer name
    # Sample data
    @commit_info[:developer_name] = '玄葉 条士郎'
    gon.developer_name = @commit_info[:developer_name]

    # Developer num
    # SampleData
    @commit_info[:developer_num] = 10;
    gon.developer_num = @commit_info[:developer_num]

  end

  def getcommits

    #repo設定
    @version_repo_id = 1
    repo_url = VersionRepository.find(@version_repo_id)[:url]
    githubRepo = repo_url.gsub(/https:\/\/github.com\//,'')

    #チーム内開発者のコミット情報を取る
    contributors = Octokit.contribs(githubRepo)

    #対象開発者の名前
    developer_name = "Altairzym"

    #@version_repo_id = 1
    #@repo_url = VersionRepository.find(@version_repo_id)[:url]
    #@version_repo = Hash.new
    #@version_repo[:url]=@repo_url.gsub(/https:\/\/github.com/,'https://api.github.com/repos')

    # get total-commits data
    #req = RestClient::Request.execute method: :get, url: @version_repo[:url]+'/stats/contributors'

    # perse
    #hash = JSON.parse(req)

    #hash.each do |json|
    #  finalstr.concat(json['author']['login'] + ":" + json['total'].to_s + "<br>")
    #end
    finalstr = ""

    #全員のコミット数
    total_commits = 0

    #対象開発者のコミット数
    developer_commits = 0

    contributors.each do |contributor|
      total_commits = total_commits + contributor['contributions']
      if contributor['login'] == developer_name then
        developer_commits = contributor['contributions']
      end
      #finalstr.concat(contributor['login'] + ":" + contributor['contributions'].to_s + "<br>")
    end

    #コミット率
    commits_rate = developer_commits.to_f/total_commits.to_f * 100

    #finalstr.concat("対象開発者: " + developer_name + "のコミット率は: " + commits_rate.round(2).to_s + "%<br>")

    #グラフ用jsonの作成
    finalstr.concat("{\"developerName\":\"" + developer_name +"\",\"developerCommit\":"+ developer_commits.to_s + ",\"totalCommit\":"+ total_commits.to_s + ",\"commitRate\":" + commits_rate.round(2).to_s + "}")

    render :json => finalstr

  end
end
