class CommitCounterController < ApplicationController
  def index
    #コミット数の集計処理をここに記載

    @commit_info = Hash.new
    
    # The number of commits
    # Sample data
    @commit_info[:count] = [11, 30, 3]
    gon.commit_count = @commit_info[:count]

    # Developer name
    # Sample data
    @commit_info[:developer_name] = ['玄葉', '戸塚', '興戸']
    gon.developer_name = @commit_info[:developer_name]
  end
end