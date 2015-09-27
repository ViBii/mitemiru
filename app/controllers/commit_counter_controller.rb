class CommitCounterController < ApplicationController
  def index
    #コミット数の集計処理をここに記載

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
    @commits_rate = (developer_commits.to_f/total_commits.to_f * 100).round(3)

    @commit_info = Hash.new

    # The number of commits
    # Sample data
    @commit_info[:own_commit] = developer_commits
    @commit_info[:all_commit] = total_commits
    gon.own_commit = @commit_info[:own_commit]
    gon.all_commit = @commit_info[:all_commit]

    # Developer name
    # Sample data
    @commit_info[:developer_name] = developer_name
    gon.developer_name = @commit_info[:developer_name]

    # Developer num
    # SampleData
    @commit_info[:developer_num] = total_developers
    gon.developer_num = @commit_info[:developer_num]

  end

end
