class VersionRepository < ActiveRecord::Base
  has_many :projects
  has_many :commit_infos
  has_many :developers, through: :commit_infos

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      # IDが見つかれば、レコードを呼び出し、見つかれなければ、新しく作成
      product = find_by(id: row["id"]) || new
      # CSVからデータを取得し、設定する
      product.attributes = row.to_hash.slice(*updatable_attributes)
      # 保存する
      product.save!
    end
  end
end
