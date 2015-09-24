class CommitCounterController < ApplicationController
  def index
    #コミット数の集計処理をここに記載

    @commit_info = Hash.new
    
    # The number of commits
    # Sample data
    @commit_info[:count] = [11, 30, 3]
    gon.commit_count = @commit_info[:count]

    # Project name
    # Sample data
    @commit_info[:project_name] = ['MITEMIRU', 'サンプルプロジェクト', '炎上プロジェクト']
    gon.project_name = @commit_info[:project_name]
  end
end
