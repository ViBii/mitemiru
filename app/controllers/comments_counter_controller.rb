class CommentsCounterController < ApplicationController
  def index

  end

  def getcomments
    #Octokit.auto_paginate = true
    issues = Octokit.list_issues("ViBii/mitemiru",state: "all")
    #issues.length
    finalstr = ""
    issues.each do |issue|
    finalstr.concat("IssueNum: " + issue['number'].to_s + " IssueTitle: " + issue['title'])
    #issue属性の中身がnilではない場合、assignee開発者の名前を表示する
      if issue['assignee'] != nil then
        finalstr.concat(" AssigneeName: "+issue['assignee']['login'] + "<br>")
      else
        finalstr.concat(" AssigneeName: nil<br>")
      end
    end
    render :text => finalstr
  end
end
