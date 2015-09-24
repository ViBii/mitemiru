class CommitCounterController < ApplicationController
  def index
    #コミット数の集計処理をここに記載

    @commit_info = Hash.new
    
    # The number of commits
    # Sample data
    @commit_info[:count] = [12, 30]
    gon.commit_count = @commit_info[:count]

    # Project ID
    # Sample data
    @commit_info[:project_id] = [1, 4]
    gon.project_id = @commit_info[:project_id]
  end
end
