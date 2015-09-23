class CommentsCounterController < ApplicationController
  def index

  end

  def getcomments
    #issuesの状態
    stateArg = "all"

    #issuesの担当者のfilter
    assigneeArg = "Altairzym"

    #認証を取る
    cl = Octokit::Client.new(login: "Altairzym", oauth_token: "c37202470329cc3edda1a82ce5943aab4942bce2")
    #repos = cl.repositories("komasaru", {sort: :pushed_at})

    cl.auto_paginate = true

    issues = cl.list_issues("ViBii/mitemiru",state: stateArg)
    #issues.length

    finalstr = ""

    issues.each do |issue|

      #assigneeArgが担当してない,かつ comment数は0ではない,かつ 担当者がnilではないissueの一覧表示
      if issue['assignee'] != nil && issue['assignee']['login'] != assigneeArg && issue['comments'] != 0 then
        #各issueのcommentsの取得
        comments = Octokit.issue_comments("octokit/octokit.rb", issue['number'].to_s)

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
