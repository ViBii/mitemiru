class CommitCounterController < ApplicationController
  def index
    #コミット数の集計処理を記載

    @commit_info = Hash.new
    # The number of commits
    @commit_info[:count] = 12

    gon.commit_count = @commit_info[:count]
  end
end
