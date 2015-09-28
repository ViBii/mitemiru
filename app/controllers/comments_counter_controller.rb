require 'json'

class CommentsCounterController < ApplicationController
  def index
#issuesの状態
    stateArg = "all"

    #見たい開発者のGithub上のUserName
    @assigneeArg = "Altairzym"

    #システム利用者github認証
    githubUserName = ENV['Github_UserName']
    githubUserPW = ENV['Github_UserPW']

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

    #同じリポジトリの中の他の開発者名前を取得する
    contributors = Octokit.contribs(githubRepo)
    developer_name = Hash.new
    contributors.each do |contributor|
      if contributor['login'] != @assigneeArg then
        developer_name[contributor['login']] = 0
      end
    end

    #issue情報を取る
    Octokit.auto_paginate = true
    issues = Octokit.list_issues(githubRepo,state: stateArg)

    #最終json
    @graph = ""
    nodes = ""
    links = ""
    @finalstr = ""

    issues.each do |issue|

      #assigneeArgが担当しなかった,かつ comment数は0ではない,かつ 担当者がnilではないissueの一覧表示
      if issue['assignee'] != nil && issue['assignee']['login'] != @assigneeArg && issue['comments'] != 0 then
        #各issueのcommentsの取得
        comments = Octokit.issue_comments(githubRepo, issue['number'].to_s)
        counter = 0
        #commentsから該当開発者の発言を合計する
        comments.each do |comment|
          if comment['user']['login'] == @assigneeArg
            counter = counter + 1
          end
        end

        #comment数を分類する
        if counter != 0 then
          developer_name.each_pair {|name, num|
            if name == issue['assignee']['login'] then
              developer_name[name] = developer_name[name] + counter
            end
          }
        end

      end
    end

    #該当開発者の設定
    nodes.concat("{\"nodes\":[{\"name\":\"" + @assigneeArg + "\",\"group\":1}")
    links.concat("],\"links\":[{\"source\":0,\"target\":")
    @finalstr.concat("開発者名: " + @assigneeArg + "<br>")
    loopTime = 0

    developer_name.each_pair {|name, num|
      if loopTime < developer_name.length then
        nodes.concat(",{\"name\":\"" + name + "\",\"group\":2}")
        links.concat((loopTime + 1).to_s + ",\"value\":")
        if loopTime != developer_name.length - 1 then
          links.concat(num.to_s + "},{\"source\":0,\"target\":")
        else
          links.concat(num.to_s + "}]}")
        end
        @finalstr.concat("開発者 " + name + " にcomment回数: " + num.to_s + "<br>")
        loopTime = loopTime + 1
      end
    }

    @graph = JSON.parse(nodes + links)
    gon.graph = @graph
  end

  def getcomments
    #issuesの状態
    stateArg = "all"

    #見たい開発者のGithub上のUserName
    assigneeArg = "yaginuuu"

    #システム利用者github認証
    githubUserName = ENV['Github_UserName']
    githubUserPW = ENV['Github_UserPW']

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

    #同じリポジトリの中の他の開発者名前を取得する
    contributors = Octokit.contribs(githubRepo)
    developer_name = Hash.new
    contributors.each do |contributor|
      if contributor['login'] != assigneeArg then
        developer_name[contributor['login']] = 0
      end
    end

    #issue情報を取る
    Octokit.auto_paginate = true
    issues = Octokit.list_issues(githubRepo,state: stateArg)

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

        #comment数を分類する
        if counter != 0 then
          developer_name.each_pair {|name, num|
            if name == issue['assignee']['login'] then
              developer_name[name] = developer_name[name] + counter
            end
          }
          finalstr.concat(issue['number'].to_s + "  " + issue['assignee']['login'] + "  "+ counter.to_s + "<br><br>")
        end

      end
    end

    finalstr.concat("合計結果:<br>開発者名: " + assigneeArg + "<br>")

    developer_name.each_pair {|name, num|
      finalstr.concat("開発者 " + name + " にcomment回数: " + num.to_s + "<br>")
    }

    render :text => finalstr
  end
end
