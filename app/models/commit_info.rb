require 'csv'   # csv操作を可能にするライブラリ
require 'kconv' # 文字コード操作をおこなうライブラリ 

class CommitInfo < ActiveRecord::Base
  belongs_to :version_repository
  belongs_to :developer

  # CSVファイルを読み込み、ユーザーを登録する
  def self.import(csv_file)
    # csvファイルを受け取って文字列にする
    csv_text = csv_file.read

    #文字列をUTF-8に変換
    CSV.parse(Kconv.toutf8(csv_text)) do |row|

      commit_info = CommitInfo.new
      commit_info.commit_id      = row[1]
      commit_info.commit_message = row[5]
      commit_info.save
    end
  end
end
