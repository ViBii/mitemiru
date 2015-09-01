require 'csv'
require 'kconv'

class CommitInfo < ActiveRecord::Base
  belongs_to :version_repository
  belongs_to :developer

  def self.import(file)
    # バリデーションは適応できたが, 
    # 現状, CommitInfoテーブルに新規追加されるので
    # どうにかしたい.
    begin
      result = []
      text   = file.read
    rescue
      return import_info = false
    end

    #文字列をUTF-8に変換
    CSV.parse(Kconv.toutf8(text)) do |row|
      result = row[0].split(" ")

      if Developer.exists?(adress: result[3])
        developer_id = Developer.where(adress: result[3]).first.id
      else
        developer = Developer.new(
        :name   => result[2],
        :adress => result[3]
        )
        developer.save
        developer_id = Developer.last.id
      end
      commit_info = CommitInfo.new(
        :version_repository_id => VersionRepository.last.present? ? VersionRepository.last.id + 1 : 1,
        :developer_id          => developer_id,
        :commit_id             => result[1],
        :commit_message        => result[6]
      )
      commit_info.save
    end
    version_repository = VersionRepository.new(
      :commit_volume => text.count("\n")
    )
    version_repository.save
    import_info = true
  end
end
