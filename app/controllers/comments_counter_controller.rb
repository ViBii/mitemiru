class CommentsCounterController < ApplicationController
  def index

  end

  def getcomments
    #issuesの状態
    stateArg = "all"

    #見たい開発者のGithub上のUserName
    assigneeArg = "Altairzym"

    #システム利用者github認証
    githubUserName = "userName"
    githubUserPW = "PW"

    #repo設定
    githubRepo = "ViBii/mitemiru"

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

    #issue情報を取る
    Octokit.auto_paginate = true
    issues = Octokit.list_issues(githubRepo,state: stateArg)

    puts issues.length

    finalstr = ""

    issues.each do |issue|

      #assigneeArgが担当しなかった,かつ comment数は0ではない,かつ 担当者がnilではないissueの一覧表示
      if issue['assignee'] != nil && issue['assignee']['login'] != assigneeArg && issue['comments'] != 0 then
        #各issueのcommentsの取得
        comments = Octokit.issue_comments(githubRepo, issue['number'].to_s)

        counter = 0

        #commentsから該当開発者の発言を合計する
        comments.each do |comment|
          if comment['user']['login'] == assigneeArg
            counter = counter + 1
          end
        end

        finalstr.concat("IssueNum: " + issue['number'].to_s + " IssueTitle: " + issue['title'])
        if issue['assignee'] != nil then
          finalstr.concat(" AssigneeName: "+issue['assignee']['login'] + " comments: " + issue['comments'].to_s + " comment回数: "+ counter.to_s + "<br><br>")
        else
          finalstr.concat(" AssigneeName: nil comments: " + issue['comments'].to_s + " comment回数: "+ counter.to_s + "<br><br>")
        end
      end
    end
    render :text => finalstr
  end
end
