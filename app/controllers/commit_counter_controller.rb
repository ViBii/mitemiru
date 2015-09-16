require 'kconv'
require 'rest-client'
require 'json'

class CommitCounterController < ApplicationController
  def index

  end

  def getcommits
    @version_repo_id = 1
    @repo_url = VersionRepository.find(@version_repo_id)[:url]
    @version_repo = Hash.new
    @version_repo[:url]=@repo_url.gsub(/https:\/\/github.com/,'https://api.github.com/repos')

    # get total-commits data
    req = RestClient::Request.execute method: :get, url: @version_repo[:url]+'/stats/contributors'

    # perse
    hash = JSON.parse(req)

    finalstr = ""
    hash.each do |json|
      # Rails.logger.info json.inspect
      finalstr.concat(json['author']['login'] + ":" + json['total'].to_s + "<br>")
    end

    render :text => finalstr

  end
end
