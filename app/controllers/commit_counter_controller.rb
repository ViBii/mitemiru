class CommitCounterController < ApplicationController
  def index
    #コミット数の集計処理をここに記載

    @commit_info = Hash.new
    
    # The number of commits
    # Sample data
    @commit_info[:own_commit] = 11
    @commit_info[:all_commit] = 90
    gon.own_commit = @commit_info[:own_commit]
    gon.all_commit = @commit_info[:all_commit]

    # Developer name
    # Sample data
    @commit_info[:developer_name] = '玄葉 条士郎'
    gon.developer_name = @commit_info[:developer_name]

    # Developer num
    # SampleData
    @commit_info[:developer_num] = 10;
    gon.developer_num = @commit_info[:developer_num]
  end
end
