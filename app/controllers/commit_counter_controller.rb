class CommitCounterController < ApplicationController
  def index
    #対象開発者の名前
    @developer_name = "Altairzym"
  end

  def commits_ajax

    #repo設定
    @version_repo_id = 1
    repo_url = VersionRepository.find(@version_repo_id)[:url]
    githubRepo = repo_url.gsub(/https:\/\/github.com\//,'')

    #チーム内開発者のコミット情報を取る
    Octokit.auto_paginate = true
    contributors = Octokit.contribs(githubRepo)

    #対象開発者の名前
    developer_name = "Altairzym"

    #全員のコミット数
    total_commits = 0

    #対象開発者のコミット数
    developer_commits = 0

    #チーム内開発者総数
    total_developers = contributors.length

    contributors.each do |contributor|
      total_commits = total_commits + contributor['contributions']
      if contributor['login'] == developer_name then
        developer_commits = contributor['contributions']
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
