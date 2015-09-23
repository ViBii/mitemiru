class CommentsCounterController < ApplicationController
  def index

  end

  def getcomments
    #issuesの状態
    stateArg = "all"

    #issuesの担当者のfilter
    assigneeArg = "Altairzym"

    Octokit.auto_paginate = true

    #複数filterの場合
    #issues = Octokit.list_issues("ViBii/mitemiru",state: stateArg,assignee: assigneeArg)

    issues = Octokit.list_issues("ViBii/mitemiru",state: stateArg)
    #issues.length

    finalstr = ""
    #issues.each do |issue|
    #finalstr.concat("IssueNum: " + issue['number'].to_s + " IssueTitle: " + issue['title'])
    #issue属性の中身がnilではない場合、assignee開発者の名前を表示する
    #  if issue['assignee'] != nil then
    #    finalstr.concat(" AssigneeName: "+issue['assignee']['login'] + "<br>")
    #  else
    #    finalstr.concat(" AssigneeName: nil<br>")
    #  end
    #end

    issues.each do |issue|

      #assigneeArgが担当してない,かつ comment数は0ではないissueの一覧表示
      if (issue['assignee'] == nil || issue['assignee']['login'] != assigneeArg) && issue['comments'] != 0 then
        finalstr.concat("IssueNum: " + issue['number'].to_s + " IssueTitle: " + issue['title'])
        if issue['assignee'] != nil then
          finalstr.concat(" AssigneeName: "+issue['assignee']['login'] + " comments: " + issue['comments'].to_s + "<br><br>")
        else
          finalstr.concat(" AssigneeName: nil comments: " + issue['comments'].to_s + "<br><br>")
        end
      end
    end
    render :text => finalstr
  end
end
